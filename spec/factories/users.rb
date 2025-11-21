# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.phone_number }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 80) }
    otp_secret { nil }
    otp_required_for_login { false }
    otp_backup_codes { [] }

    trait :with_mfa do
      otp_secret { ROTP::Base32.random }
      otp_required_for_login { true }
      otp_backup_codes { Array.new(10) { SecureRandom.hex(4).upcase } }
    end

    trait :admin do
      after(:create) do |user|
        user.add_role(:admin)
      end
    end
  end
end

