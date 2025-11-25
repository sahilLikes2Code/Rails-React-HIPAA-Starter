# frozen_string_literal: true

class DataSubjectRequest < ApplicationRecord
  belongs_to :user

  enum request_type: {
    access: "access",
    erasure: "erasure",
    export: "export"
  }, _suffix: true

  enum status: {
    queued: "queued",
    processing: "processing",
    completed: "completed",
    rejected: "rejected"
  }, _suffix: true

  validates :data_subject_identifier, presence: true
  validates :request_type, inclusion: { in: request_types.keys }

  before_validation :apply_defaults
  before_save :stamp_completion

  scope :open_requests, -> { where(status: %w[queued processing]) }

  def mark_processing!
    update!(status: :processing)
  end

  def mark_completed!(note = nil)
    update!(status: :completed, completed_at: Time.current, notes: [notes, note].compact.join("\n"))
  end

  private

  def apply_defaults
    self.data_subject_identifier ||= user&.email
    self.due_at ||= 30.days.from_now
  end

  def stamp_completion
    return unless will_save_change_to_status?
    return unless status == "completed"

    self.completed_at ||= Time.current
  end
end

