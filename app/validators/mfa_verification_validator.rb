# frozen_string_literal: true

class MfaVerificationValidator
  include Dry::Validation::Contract

  params do
    required(:user_id).filled(:string)
    required(:password).filled(:string)
    required(:otp_code).filled(:string, format?: /\A\d{6}\z/)
  end

  rule(:otp_code) do
    unless value.match?(/\A\d{6}\z/)
      key.failure("must be a 6-digit code")
    end
  end
end

