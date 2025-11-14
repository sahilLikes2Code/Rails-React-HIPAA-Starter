# frozen_string_literal: true

# Data Retention Policy Service for HIPAA Compliance
# Minimum 6-year retention for audit logs required
# Configure retention periods per data type
class DataRetentionPolicy
  # Define retention periods (adjust based on your requirements)
  RETENTION_PERIODS = {
    "User" => 7.years,
    "AuditLog" => 6.years # Minimum for HIPAA
  }.freeze

  def self.purge_expired
    RETENTION_PERIODS.each do |model_name, retention_period|
      model = model_name.constantize
      expired_records = model.where("created_at < ?", retention_period.ago)

      expired_records.find_each do |record|
        # Log the purge action
        Rails.logger.info("Purging #{model_name} ID: #{record.id} created at: #{record.created_at}")

        # Actually delete the record
        record.destroy!
      end
    end
  end
end

