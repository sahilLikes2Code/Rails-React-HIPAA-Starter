# frozen_string_literal: true

# User model with HIPAA compliance enabled
# NOTE: Customize PHI fields based on your application's requirements
class User < ApplicationRecord
  # Devise modules - customize based on your needs
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :two_factor_authenticatable, :two_factor_backupable

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
  # This tracks all modifications to user data (required for HIPAA)
  has_paper_trail

  # MFA configuration
  attr_accessor :otp_attempt

  # Generate backup codes (10 codes by default)
  self.otp_backup_code_length = 10

  # Generate TOTP secret for MFA setup
  def generate_two_factor_secret!
    secret = ROTP::Base32.random
    
    # Use update_column to bypass validations and ensure it saves
    update_column(:otp_secret, secret)
    
    # Verify it was saved
    reload
    unless otp_secret == secret
      raise "Failed to save OTP secret"
    end
    
    secret
  end

  # Generate QR code for MFA setup
  def qr_code
    return nil unless otp_secret

    require "rqrcode"
    provisioning_uri = ROTP::TOTP.new(otp_secret, issuer: Rails.application.class.module_parent_name).provisioning_uri(email)
    qr = RQRCode::QRCode.new(provisioning_uri)
    qr
  end

  # Generate QR code as SVG string
  def qr_code_svg
    qr = qr_code
    return nil unless qr

    qr.as_svg(module_size: 4)
  end

  # Verify OTP code
  def verify_otp(code)
    return false unless otp_secret
    return false if code.blank?

    # Clean the code - remove whitespace and convert to string
    clean_code = code.to_s.strip.gsub(/\s+/, "")
    
    # Ensure code is exactly 6 digits
    return false unless clean_code.match?(/\A\d{6}\z/)

    # Create TOTP instance (issuer is only needed for QR code generation, not verification)
    totp = ROTP::TOTP.new(otp_secret)
    
    # Verify with wider time window to account for clock drift
    # verify returns timestamp if valid, nil if invalid
    result = totp.verify(clean_code, drift_behind: 30, drift_ahead: 30)
    
    # Return true if verification succeeded (result is a timestamp), false otherwise
    !!result
  end

  # Check if MFA is enabled
  def two_factor_enabled?
    otp_required_for_login?
  end

  # Role-based authorization using Rolify
  rolify
end

