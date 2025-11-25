# frozen_string_literal: true

# Optional webhook fan-out so compliance/security events reach an alerting tool
# (PagerDuty, Slack, Opsgenie, etc.). Set MONITORING_WEBHOOK_URL to enable.
require "net/http"
require "uri"

module MonitoringHooks
  def self.enabled?
    ENV["MONITORING_WEBHOOK_URL"].present?
  end

  def self.webhook_uri
    URI.parse(ENV["MONITORING_WEBHOOK_URL"])
  end

  def self.deliver(event_name:, payload:)
    return unless enabled?

    http = Net::HTTP.new(webhook_uri.host, webhook_uri.port)
    http.use_ssl = webhook_uri.scheme == "https"

    request = Net::HTTP::Post.new(webhook_uri.request_uri, { "Content-Type" => "application/json" })
    request.body = {
      event: event_name,
      payload: payload,
      sent_at: Time.current
    }.to_json

    http.request(request)
  rescue StandardError => e
    Rails.logger.error("Monitoring webhook delivery failed: #{e.message}")
  end
end

if MonitoringHooks.enabled?
  ActiveSupport::Notifications.subscribe("compliance.audit") do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    severity = case event.payload[:event_type]
               when /incident|breach/ then "critical"
               when /rack_attack|rate_limit/ then "warning"
               else "info"
               end

    MonitoringHooks.deliver(
      event_name: "compliance.audit",
      payload: event.payload.merge(severity: severity, duration_ms: event.duration.round(2))
    )
  end

  ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    status = event.payload[:status]
    next unless status.to_i >= 500

    MonitoringHooks.deliver(
      event_name: "http.error",
      payload: {
        controller: event.payload[:controller],
        action: event.payload[:action],
        format: event.payload[:format],
        path: event.payload[:path],
        status: status,
        duration_ms: event.duration.round(2)
      }
    )
  end
end

