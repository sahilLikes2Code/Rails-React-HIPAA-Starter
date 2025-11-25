# frozen_string_literal: true

class MfaVerificationValidator < Dry::Validation::Contract
  params do
    required(:user_id).filled(:string)
    required(:password).filled(:string)
    required(:otp_code).filled(:string)
  end

  rule(:otp_code) do
    # Accept either 6-digit OTP codes or backup codes (8 hex characters)
    unless value.match?(/\A\d{6}\z/) || value.match?(/\A[A-Z0-9]{8}\z/i)
      key.failure("must be a 6-digit OTP code or an 8-character backup code")
    end
  end
end

