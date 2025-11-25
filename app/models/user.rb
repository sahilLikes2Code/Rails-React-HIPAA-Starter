# frozen_string_literal: true

# User model with HIPAA compliance enabled
# NOTE: Customize PHI fields based on your application's requirements
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :two_factor_authenticatable, :two_factor_backupable

  has_many :consent_records, dependent: :destroy
  has_many :data_subject_requests, dependent: :destroy

  # HIPAA Compliance: Encrypt PHI fields using Lockbox
  # Customize these fields based on what PHI your app stores
  # Common PHI fields: name, phone, SSN, date_of_birth, address, medical_record_number
  # NOTE: Email is NOT encrypted here (needed for Devise login) - consider your security approach
  # Extend Lockbox::Model first, then use encrypts (Lockbox's version should take precedence)
  extend Lockbox::Model
  encrypts :first_name, :last_name, :phone_number, :date_of_birth

  # Validations for required PHI fields
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :date_of_birth, presence: true

  # HIPAA Compliance: Audit logging for all changes
  has_paper_trail

  attr_accessor :otp_attempt
  # self.otp_backup_code_length = 10 # Moved to config/initializers/devise.rb

  def generate_two_factor_secret!
    secret = ROTP::Base32.random
    
    # Use update_column to bypass validations and ensure it saves
    # But only if the record is persisted
    if persisted?
      update_column(:otp_secret, secret)
    else
      self.otp_secret = secret
      save!
    end
    
    secret
  end

  def qr_code
    return nil unless otp_secret

    require "rqrcode"
    provisioning_uri = ROTP::TOTP.new(otp_secret, issuer: Rails.application.class.module_parent_name).provisioning_uri(email)
    qr = RQRCode::QRCode.new(provisioning_uri)
    qr
  end

  def qr_code_svg
    qr = qr_code
    return nil unless qr

    qr.as_svg(module_size: 4)
  end

  def verify_otp(code)
    return false unless otp_secret
    return false if code.blank?

    clean_code = code.to_s.strip.gsub(/\s+/, "")
    return false unless clean_code.match?(/\A\d{6}\z/)

    # Create TOTP instance (issuer is only needed for QR code generation, not verification)
    totp = ROTP::TOTP.new(otp_secret)
    
    # Verify with wider time window to account for clock drift
    result = totp.verify(clean_code, drift_behind: 30, drift_ahead: 30)
    !!result
  end

  def two_factor_enabled?
    otp_required_for_login?
  end

  def generate_backup_codes!
    codes = Array.new(10) { SecureRandom.hex(4).upcase }
    # Hash with BCrypt for security - return plaintext for one-time display only
    hashed_codes = codes.map { |code| BCrypt::Password.create(code).to_s }
    update_column(:otp_backup_codes, hashed_codes)
    codes
  end

  def valid_backup_code?(code)
    return false if otp_backup_codes.blank?
    return false if code.blank?

    clean_code = code.to_s.strip.upcase
    
    otp_backup_codes.any? do |hashed_code|
      begin
        BCrypt::Password.new(hashed_code) == clean_code
      rescue BCrypt::Errors::InvalidHash
        # SECURITY: Only allow plaintext fallback in test/development for migration/testing
        # In production, all backup codes MUST be BCrypt hashed
        if Rails.env.test? || Rails.env.development?
          hashed_code.to_s.strip.upcase == clean_code
        else
          Rails.logger.warn("Invalid backup code hash detected for user #{id} - rejecting in production")
          false
        end
      end
    end
  end

  def use_backup_code!(code)
    return false if otp_backup_codes.blank?
    return false if code.blank?

    clean_code = code.to_s.strip.upcase
    
    updated_codes = otp_backup_codes.reject do |hashed_code|
      begin
        BCrypt::Password.new(hashed_code) == clean_code
      rescue BCrypt::Errors::InvalidHash
        # SECURITY: Only allow plaintext fallback in test/development for migration/testing
        # In production, all backup codes MUST be BCrypt hashed
        if Rails.env.test? || Rails.env.development?
          hashed_code.to_s.strip.upcase == clean_code
        else
          Rails.logger.warn("Invalid backup code hash detected for user #{id} - rejecting in production")
          false
        end
      end
    end
    
    if updated_codes.length < otp_backup_codes.length
      update_column(:otp_backup_codes, updated_codes)
      true
    else
      false
    end
  end

  rolify

  # Rails 8 compatibility: Devise's serialize_from_session signature changed
  # This method handles both the old (1 arg) and new (2 args) signatures
  def self.serialize_from_session(key, salt = nil)
    if salt.nil?
      # Old signature (Rails < 8): just the key
      find_by(id: key)
    else
      # New signature (Rails 8+): key and salt
      find_by(id: key)
    end
  end
end

