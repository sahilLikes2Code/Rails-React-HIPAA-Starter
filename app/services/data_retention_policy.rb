# frozen_string_literal: true

# Data Retention Policy Service for HIPAA, SOC 2, and GDPR alignment.
# Minimum 6-year retention for HIPAA audit logs plus configurable periods
# for EU personal data and SOC 2 evidence.
require "json"
require "active_support/core_ext/string/inflections"

class DataRetentionPolicy
  # Define retention periods (adjust based on your requirements)
  DEFAULT_RETENTION_PERIODS = {
    "User" => 7.years,
    "AuditLog" => 6.years, # HIPAA minimum
    "PaperTrail::Version" => 6.years,
    "SecurityEvent" => 1.year, # infrastructure + monitoring evidence
    "ConsentRecord" => 2.years # GDPR recommended baseline
  }.freeze

  def self.purge_expired
    retention_periods.each do |model_name, retention_period|
      model = model_name.safe_constantize
      unless model
        Rails.logger.debug("DataRetentionPolicy: skipping #{model_name} (model not loaded)")
        next
      end

      expired_records = model.where("created_at < ?", retention_period.ago)

      expired_records.find_each do |record|
        # Log the purge action
        Rails.logger.info("Purging #{model_name} ID: #{record.id} created at: #{record.created_at}")
        if defined?(Compliance::AuditLogger)
          Compliance::AuditLogger.log(
            event_type: "data_retention.purge",
            actor: "system",
            resource: "#{model_name}##{record.id}",
            metadata: { retention_period_days: (retention_period / 1.day).to_i }
          )
        end

        # Actually delete the record
        record.destroy!
      end
    end
  end

  def self.retention_periods
    @retention_periods ||= DEFAULT_RETENTION_PERIODS.merge(env_overrides)
  end

  def self.forget_data_subject(identifier:, models: %w[ConsentRecord DataSubjectRequest])
    raise ArgumentError, "identifier required" if identifier.blank?

    models.each do |model_name|
      model = model_name.safe_constantize
      next unless model&.column_names&.include?("data_subject_identifier")

      model.where(data_subject_identifier: identifier).find_each do |record|
        Rails.logger.info("GDPR forget request removing #{model_name}##{record.id} for #{identifier}")
        Compliance::AuditLogger.log(
          event_type: "gdpr.forget",
          actor: "system",
          resource: "#{model_name}##{record.id}",
          metadata: { identifier: identifier }
        ) if defined?(Compliance::AuditLogger)
        record.destroy!
      end
    end
  end

  def self.env_overrides
    raw = ENV["DATA_RETENTION_OVERRIDES"]
    return {} if raw.blank?

    JSON.parse(raw).each_with_object({}) do |(model_name, days), memo|
      numeric_days = days.to_i
      next if numeric_days.zero?

      memo[model_name] = numeric_days.days
    end
  rescue JSON::ParserError => e
    Rails.logger.error("Invalid DATA_RETENTION_OVERRIDES JSON: #{e.message}")
    {}
  end
end

