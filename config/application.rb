require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module RailsReactHipaaStarter
  class Application < Rails::Application
    config.load_defaults 7.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.generators.system_tests = nil

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.middleware.use Rack::Attack

    # Configure Rails encryption to not interfere with Lockbox
    # We use Lockbox for encryption, but Rails 7.1 defines encrypts method
    # Setting these prevents Rails from requiring keys when encrypts is called
    config.active_record.encryption.support_unencrypted_data = true
    # Set dummy keys so Rails doesn't error (Lockbox handles actual encryption)
    config.active_record.encryption.primary_key = ENV.fetch("RAILS_ENCRYPTION_PRIMARY_KEY", "dummy_key_not_used")
    config.active_record.encryption.deterministic_key = ENV.fetch("RAILS_ENCRYPTION_DETERMINISTIC_KEY", "dummy_key_not_used")
    config.active_record.encryption.key_derivation_salt = ENV.fetch("RAILS_ENCRYPTION_KEY_DERIVATION_SALT", "dummy_salt_not_used")

    # HIPAA Compliance: Filter sensitive parameters from logs
    # Prevents passwords, PHI, and other sensitive data from appearing in logs
    config.filter_parameters += [
      :password,
      :password_confirmation,
      :current_password,
      :otp_attempt,
      :otp_secret,
      :otp_backup_codes,
      # PHI fields (encrypted but still shouldn't be logged)
      :email,
      :first_name,
      :last_name,
      :phone_number,
      :date_of_birth,
      :ssn,
      :social_security_number,
      :medical_record_number,
      :diagnosis,
      :treatment_notes,
      :medication_list,
      :allergies,
      :lab_results,
      :imaging_notes,
      # Credit card and payment info
      :credit_card,
      :card_number,
      :cvv,
      :cvc,
      :card_verification_value,
      # API keys and tokens
      :api_key,
      :access_token,
      :secret_key,
      :private_key
    ]

    # Disable Sprockets SCSS compilation since we use cssbundling-rails
    config.assets.css_compressor = nil
  end
end

