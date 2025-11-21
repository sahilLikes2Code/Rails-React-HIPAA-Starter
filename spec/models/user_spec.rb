# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "requires first_name" do
      user = build(:user, first_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it "requires last_name" do
      user = build(:user, last_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it "requires phone_number" do
      user = build(:user, phone_number: nil)
      expect(user).not_to be_valid
      expect(user.errors[:phone_number]).to include("can't be blank")
    end

    it "requires date_of_birth" do
      user = build(:user, date_of_birth: nil)
      expect(user).not_to be_valid
      expect(user.errors[:date_of_birth]).to include("can't be blank")
    end
  end

  describe "encryption" do
    let(:user) { create(:user, first_name: "John", last_name: "Doe", phone_number: "123-456-7890", date_of_birth: Date.new(1990, 1, 1)) }

    it "stores PHI fields and makes them accessible" do
      # Lockbox encrypts fields - verify they're accessible through accessors
      # Note: Lockbox may return dates as strings when encrypted/decrypted
      expect(user.first_name).to eq("John")
      expect(user.last_name).to eq("Doe")
      expect(user.phone_number).to eq("123-456-7890")
      # Date may be returned as string by Lockbox, so convert for comparison
      date_value = user.date_of_birth
      expected_date = Date.new(1990, 1, 1)
      if date_value.is_a?(String)
        expect(Date.parse(date_value)).to eq(expected_date)
      else
        expect(date_value).to eq(expected_date)
      end
    end

    it "has ciphertext columns in database schema" do
      # Verify that Lockbox ciphertext columns exist in the database
      raw_attrs = user.attributes
      expect(raw_attrs.keys).to include("first_name_ciphertext", "last_name_ciphertext", 
                                         "phone_number_ciphertext", "date_of_birth_ciphertext")
    end

    it "allows setting and reading PHI fields" do
      # Test basic read/write functionality
      user.first_name = "Jane"
      user.last_name = "Smith"
      expect(user.first_name).to eq("Jane")
      expect(user.last_name).to eq("Smith")
    end

    it "maintains data integrity across operations" do
      # Test that we can read what we write
      original_email = user.email
      user.update(first_name: "UpdatedName")
      expect(user.first_name).to eq("UpdatedName")
      expect(user.email).to eq(original_email) # Other fields unchanged
    end
  end

  describe "MFA" do
    describe "#generate_two_factor_secret!" do
      let(:user) { create(:user) }

      it "generates a secret" do
        secret = user.generate_two_factor_secret!
        expect(secret).to be_present
        expect(secret.length).to be >= 16
      end

      it "saves the secret to the database" do
        secret = user.generate_two_factor_secret!
        user.reload
        expect(user.otp_secret).to eq(secret)
      end

      it "can regenerate secret if called again" do
        original_secret = user.generate_two_factor_secret!
        user.reload
        expect(user.otp_secret).to eq(original_secret)
        # The method itself doesn't prevent regeneration - it always generates
        # But controllers should check before calling (see two_factor_setup_controller)
        new_secret = user.generate_two_factor_secret!
        expect(new_secret).not_to eq(original_secret)
        expect(new_secret).to be_present
      end
    end

    describe "#verify_otp" do
      let(:user) { create(:user, :with_mfa) }

      it "verifies a valid OTP code" do
        totp = ROTP::TOTP.new(user.otp_secret)
        code = totp.now
        expect(user.verify_otp(code)).to be true
      end

      it "rejects an invalid OTP code" do
        expect(user.verify_otp("000000")).to be false
      end

      it "rejects blank codes" do
        expect(user.verify_otp("")).to be false
        expect(user.verify_otp(nil)).to be false
      end

      it "rejects codes that are not 6 digits" do
        expect(user.verify_otp("12345")).to be false
        expect(user.verify_otp("1234567")).to be false
      end
    end

    describe "#two_factor_enabled?" do
      it "returns false when MFA is not enabled" do
        user = create(:user)
        expect(user.two_factor_enabled?).to be false
      end

      it "returns true when MFA is enabled" do
        user = create(:user, :with_mfa)
        expect(user.two_factor_enabled?).to be true
      end
    end

    describe "#generate_backup_codes!" do
      let(:user) { create(:user) }

      it "generates 10 backup codes" do
        codes = user.generate_backup_codes!
        expect(codes.length).to eq(10)
        codes.each do |code|
          expect(code).to match(/\A[A-F0-9]{8}\z/)
        end
      end

      it "saves backup codes to database" do
        codes = user.generate_backup_codes!
        user.reload
        expect(user.otp_backup_codes).to eq(codes)
      end
    end

    describe "#valid_backup_code?" do
      let(:user) { create(:user) }

      before do
        user.update_column(:otp_backup_codes, ["ABCD1234", "EFGH5678"])
      end

      it "validates a correct backup code" do
        expect(user.valid_backup_code?("ABCD1234")).to be true
        expect(user.valid_backup_code?("abcd1234")).to be true # case insensitive
      end

      it "rejects an invalid backup code" do
        expect(user.valid_backup_code?("INVALID")).to be false
      end

      it "rejects blank codes" do
        expect(user.valid_backup_code?("")).to be false
        expect(user.valid_backup_code?(nil)).to be false
      end
    end

    describe "#use_backup_code!" do
      let(:user) { create(:user) }

      before do
        user.update_column(:otp_backup_codes, ["ABCD1234", "EFGH5678"])
      end

      it "removes the used backup code" do
        expect(user.use_backup_code!("ABCD1234")).to be true
        user.reload
        expect(user.otp_backup_codes).not_to include("ABCD1234")
        expect(user.otp_backup_codes).to include("EFGH5678")
      end

      it "returns false for invalid codes" do
        expect(user.use_backup_code!("INVALID")).to be false
      end
    end
  end

  describe "audit logging" do
    it "has paper trail enabled" do
      user = create(:user)
      expect(user.versions.count).to eq(1) # creation version
    end

    it "tracks changes to user" do
      user = create(:user, first_name: "John")
      user.update(first_name: "Jane")
      expect(user.versions.count).to eq(2)
      expect(user.versions.last.event).to eq("update")
    end
  end
end

