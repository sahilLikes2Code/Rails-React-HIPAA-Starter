# frozen_string_literal: true

# Background job for automated data retention/purging
# Schedule with Whenever (config/schedule.rb)
class DataRetentionJob
  include Sidekiq::Worker

  def perform
    DataRetentionPolicy.purge_expired
  end
end

