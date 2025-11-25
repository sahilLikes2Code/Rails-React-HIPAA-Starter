# frozen_string_literal: true

class ProcessDataSubjectRequestJob < ApplicationJob
  queue_as :default

  def perform(request_id)
    request = DataSubjectRequest.find(request_id)
    request.mark_processing!

    # Placeholder for actual export/erasure logic.
    sleep 0.1 # simulate processing time for demo purposes

    request.mark_completed!("Processed automatically by ProcessDataSubjectRequestJob.")

    if defined?(Compliance::AuditLogger)
      Compliance::AuditLogger.log(
        event_type: "gdpr.request.#{request.request_type}",
        actor: request.user.email,
        resource: "DataSubjectRequest##{request.id}",
        metadata: {
          status: request.status,
          due_at: request.due_at,
          completed_at: request.completed_at
        }
      )
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("DataSubjectRequest #{request_id} disappeared before processing")
  end
end

