# frozen_string_literal: true

# Subscribe to structured compliance events and mirror them into a dedicated
# log file that can be shipped to your SIEM for SOC 2 evidence.
require "fileutils"
audit_log_path = Rails.root.join("log", "compliance.log")
FileUtils.touch(audit_log_path) unless File.exist?(audit_log_path)

audit_logger = ActiveSupport::Logger.new(audit_log_path)
audit_logger.formatter = Logger::Formatter.new

ActiveSupport::Notifications.subscribe("compliance.audit") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  payload = event.payload.merge(duration_ms: event.duration.round(2))
  audit_logger.info(payload.to_json)
end

# Emit a boot event so operators know the subscription is live.
if defined?(Compliance::AuditLogger)
  Compliance::AuditLogger.log(
    event_type: "audit_channel.boot",
    actor: "system",
    resource: "audit_log_subscriptions",
    metadata: { log_path: audit_log_path.to_s }
  )
end

