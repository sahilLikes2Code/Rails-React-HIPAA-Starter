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

