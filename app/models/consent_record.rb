# frozen_string_literal: true

class ConsentRecord < ApplicationRecord
  belongs_to :user, optional: true

  validates :data_subject_identifier, presence: true
  validates :purpose, presence: true

  scope :granted, -> { where(granted: true, revoked_at: nil) }

  before_validation :fallback_identifier
  before_save :stamp_state_change

  def revoke!
    update!(granted: false)
  end

  private

  def fallback_identifier
    self.data_subject_identifier ||= user&.email
  end

  def stamp_state_change
    return unless will_save_change_to_granted?

    if granted
      self.granted_at = Time.current
      self.revoked_at = nil
    else
      self.revoked_at = Time.current
    end
  end
end

