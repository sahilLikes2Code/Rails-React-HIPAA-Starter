# frozen_string_literal: true

module Compliance
  # Central helper for emitting structured audit events that can be
  # forwarded to PaperTrail, SIEM, or additional log targets.
  class AuditLogger
    CHANNEL = "compliance.audit"

    def self.log(event_type:, actor:, resource:, metadata: {})
      payload = {
        event_type: event_type,
        actor: actor,
        resource: resource,
        metadata: metadata,
        occurred_at: Time.current
      }

      ActiveSupport::Notifications.instrument(CHANNEL, payload)
    end
  end
end

