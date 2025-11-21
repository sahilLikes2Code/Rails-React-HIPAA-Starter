# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::TwoFactorSetupController, type: :controller do
  def parsed_response
    JSON.parse(response.body)
  end

  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET #new" do
    it "generates a QR code URL" do
      get :new
      expect(response).to have_http_status(:ok)
      expect(parsed_response["success"]).to be true
      expect(parsed_response["data"]["qr_code_url"]).to be_present
      expect(parsed_response["data"]["qr_code_url"]).to start_with("data:image/svg+xml;base64,")
    end

    it "generates an OTP secret if one doesn't exist" do
      expect(user.otp_secret).to be_nil
      get :new
      user.reload
      expect(user.otp_secret).to be_present
    end

    it "does not regenerate secret if one exists" do
      original_secret = user.generate_two_factor_secret!
      user.reload
      expect(user.otp_secret).to eq(original_secret)
      # Controller checks before generating, so it won't regenerate
      get :new
      user.reload
      expect(user.otp_secret).to eq(original_secret)
    end
  end

  describe "POST #create" do
    before do
      user.generate_two_factor_secret!
    end

    context "with valid OTP code" do
      it "enables MFA and generates backup codes" do
        totp = ROTP::TOTP.new(user.otp_secret)
        code = totp.now

        post :create, params: { otp_attempt: code }

        expect(response).to have_http_status(:ok)
        expect(parsed_response["success"]).to be true
        expect(parsed_response["data"]["two_factor_enabled"]).to be true
        expect(parsed_response["data"]["backup_codes"]).to be_present
        expect(parsed_response["data"]["backup_codes"].length).to eq(10)

        # Reload user from database to get updated state
        # The controller updates current_user, so we need to reload our test instance
        user.reload
        # Also verify by finding the user fresh from database
        updated_user = User.find(user.id)
        expect(updated_user.otp_required_for_login).to be true
        expect(updated_user.otp_backup_codes.length).to eq(10)
      end
    end

    context "with invalid OTP code" do
      it "returns an error" do
        post :create, params: { otp_attempt: "000000" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["success"]).to be false
        expect(parsed_response["error"]).to be_present

        user.reload
        expect(user.otp_required_for_login).to be false
      end
    end

    context "without OTP secret" do
      it "returns an error" do
        user.update_column(:otp_secret, nil)

        post :create, params: { otp_attempt: "123456" }

        expect(response).to have_http_status(:bad_request)
        expect(parsed_response["success"]).to be false
      end
    end
  end

  describe "DELETE #destroy" do
    let(:user_with_mfa) { create(:user, :with_mfa) }

    before do
      sign_in user_with_mfa
    end

    it "disables MFA" do
      delete :destroy

      expect(response).to have_http_status(:ok)
      expect(parsed_response["success"]).to be true
      expect(parsed_response["data"]["two_factor_enabled"]).to be false

      # Reload to get updated state from database
      # The controller updates current_user, so find fresh from database
      updated_user = User.find(user_with_mfa.id)
      expect(updated_user.otp_required_for_login).to be false
      expect(updated_user.otp_secret).to be_nil
      expect(updated_user.otp_backup_codes).to eq([])
    end
  end

  describe "GET #backup_codes" do
    let(:user_with_mfa) { create(:user, :with_mfa) }

    before do
      sign_in user_with_mfa
    end

    it "returns backup codes" do
      get :backup_codes

      expect(response).to have_http_status(:ok)
      expect(parsed_response["success"]).to be true
      expect(parsed_response["data"]["backup_codes"]).to eq(user_with_mfa.otp_backup_codes)
    end
  end
end

