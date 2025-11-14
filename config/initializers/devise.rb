# frozen_string_literal: true

Devise.setup do |config|
  # Configure email sender - use environment variable or default
  config.mailer_sender = ENV.fetch("MAILER_SENDER", "please-change-me-at-config-initializers-devise@example.com")
  require "devise/orm/active_record"

  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 12

  config.reconfirmable = true

  config.expire_all_remember_me_on_sign_out = true

  config.password_length = 6..128

  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours

  config.sign_out_via = :delete

  # Two-factor authentication configuration (HIPAA Compliance)
  # MFA is enabled on User model - users must set up TOTP after registration
  # See: https://github.com/tinybike/devise-two-factor
end

