# frozen_string_literal: true

# Test MFA setup and verification
# Usage: rails mfa:test[user_email]
namespace :mfa do
  desc "Test MFA setup for a user"
  task :test, [:email] => :environment do |_t, args|
    email = args[:email] || "oliver@example.com"
    user = User.find_by(email: email)
    
    unless user
      puts "User not found: #{email}"
      exit 1
    end
    
    puts "=== MFA Test for #{user.email} ==="
    puts "Current OTP Secret: #{user.otp_secret.present? ? 'Present' : 'Missing'}"
    
    # Generate secret if missing
    if user.otp_secret.blank?
      puts "Generating new OTP secret..."
      user.generate_two_factor_secret!
      user.reload
    end
    
    puts "OTP Secret: #{user.otp_secret.first(20)}..."
    
    # Generate QR code URI
    totp = ROTP::TOTP.new(user.otp_secret, issuer: Rails.application.class.module_parent_name)
    provisioning_uri = totp.provisioning_uri(user.email)
    puts "Provisioning URI: #{provisioning_uri}"
    
    # Get current code
    current_code = totp.now
    puts "Current TOTP Code: #{current_code}"
    puts ""
    puts "Test verification with current code:"
    result = user.verify_otp(current_code)
    puts "Verification result: #{result ? 'SUCCESS' : 'FAILED'}"
    puts ""
    puts "Enter a code from your authenticator app to test:"
    test_code = STDIN.gets.chomp
    test_result = user.verify_otp(test_code)
    puts "Test code verification: #{test_result ? 'SUCCESS' : 'FAILED'}"
  end
end

