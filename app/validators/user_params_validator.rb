# frozen_string_literal: true

# Input validation for user parameters - prevents injection attacks (HIPAA Compliance)
class UserParamsValidator
  include Dry::Validation::Contract

  params do
    required(:email).filled(:string, format?: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
    required(:password).filled(:string, min_size?: 8)
    required(:first_name).filled(:string, max_size?: 255)
    required(:last_name).filled(:string, max_size?: 255)
    required(:phone_number).filled(:string)
    required(:date_of_birth).filled(:string)
    optional(:password_confirmation).filled(:string)
  end

  rule(:password) do
    if value
      if value.length < 8
        key.failure("must be at least 8 characters")
      end
      unless value.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])/)
        key.failure("must include uppercase, lowercase, number, and special character (@$!%*?&#)")
      end
    end
  end

  rule(:password_confirmation) do
    if values[:password] && value && value != values[:password]
      key.failure("doesn't match password")
    end
  end

  rule(:date_of_birth) do
    if value
      begin
        parsed_date = Date.parse(value)
        if parsed_date > 18.years.ago
          key.failure("must be at least 18 years ago")
        end
        if parsed_date < 120.years.ago
          key.failure("must be a valid date")
        end
      rescue ArgumentError, TypeError
        key.failure("must be a valid date")
      end
    end
  end

  rule(:phone_number) do
    unless value.match?(/\A[\d\s\-\+\(\)]+\z/)
      key.failure("must be a valid phone number")
    end
  end

  rule(:first_name, :last_name) do
    # XSS prevention - block potentially dangerous characters
    [:first_name, :last_name].each do |field|
      if values[field] && values[field].match?(/[<>]/)
        key(field).failure("contains invalid characters")
      end
    end
  end
end

