# Lockbox encryption configuration for HIPAA compliance
# Set LOCKBOX_MASTER_KEY in rails credentials or environment variable
# Run: rails credentials:edit
# Add: lockbox_master_key: <your-key-here>
# Or set: LOCKBOX_MASTER_KEY environment variable

# Try to get key from credentials, but handle case where credentials can't be decrypted
lockbox_key = nil
begin
  lockbox_key = Rails.application.credentials.dig(:lockbox_master_key) if Rails.application.credentials
rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::EncryptedFile::MissingKeyError
  # Credentials file exists but can't be decrypted (no master.key)
  # This is normal for cloned repositories - will use ENV or generate temp key
  Rails.logger.info "ℹ️  Credentials file cannot be decrypted (no master.key). Using ENV or generating temporary key."
end

Lockbox.master_key = lockbox_key || ENV["LOCKBOX_MASTER_KEY"]

# In development and test, generate a temporary key if not set (for testing only)
# In production, this key MUST be set properly
if Lockbox.master_key.blank?
  if Rails.env.development? || Rails.env.test?
    # Generate a temporary key for development/test (not secure, for testing only)
    Lockbox.master_key = SecureRandom.hex(32)
    Rails.logger.warn "⚠️  WARNING: Using temporary Lockbox key for #{Rails.env}. Set LOCKBOX_MASTER_KEY in credentials or ENV for production!" unless Rails.env.test?
  else
    raise "LOCKBOX_MASTER_KEY must be set in credentials or environment variable"
  end
end

# NOTE: The following ActiveRecord Encryption configuration was moved to config/application.rb
# # Configure Active Record Encryption for Rails 8+ (required even with Lockbox)
# # These keys are generated via `rails db:encryption:init`
# Rails.application.config.active_record_encryption.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY") do
#   # Only generate temporary keys for test environment
#   if Rails.env.test?
#     SecureRandom.hex(32)
#   else
#     raise "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY must be set in credentials or environment variable"
#   end
# end
# Rails.application.config.active_record_encryption.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY") do
#   if Rails.env.test?
#     SecureRandom.hex(32)
#   else
#     raise "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY must be set in credentials or environment variable"
#   end
# end
# Rails.application.config.active_record_encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT") do
#   if Rails.env.test?
#     SecureRandom.hex(33)
#   else
#     raise "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT must be set in credentials or environment variable"
#   end
# end

