# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SessionsController, type: :controller do
  def parsed_response
    JSON.parse(response.body)
  end
  describe "POST #create" do
    let(:password) { "Password123!" }
    let(:user) { create(:user, password: password, password_confirmation: password) }

    context "with valid credentials" do
      context "without MFA enabled" do
        it "signs in the user" do
          post :create, params: { user: { email: user.email, password: password } }
          expect(response).to have_http_status(:ok)
          expect(parsed_response["success"]).to be true
          expect(parsed_response["data"]["user"]["email"]).to eq(user.email)
        end
      end

      context "with MFA enabled" do
        let(:user_with_mfa) { create(:user, :with_mfa, password: password, password_confirmation: password) }

        it "does not sign in the user" do
          post :create, params: { user: { email: user_with_mfa.email, password: password } }
          expect(response).to have_http_status(:ok)
          expect(parsed_response["success"]).to be false
          expect(parsed_response["requires_mfa"]).to be true
          expect(parsed_response["user_id"]).to eq(user_with_mfa.id.to_s)
        end
      end
    end

    context "with invalid credentials" do
      it "returns an error" do
        post :create, params: { user: { email: user.email, password: "wrong_password" } }
        expect(response).to have_http_status(:unauthorized)
        expect(parsed_response["success"]).to be false
        expect(parsed_response["error"]).to be_present
      end
    end
  end

  describe "POST #verify_mfa" do
    let(:password) { "Password123!" }
    let(:user) { create(:user, :with_mfa, password: password, password_confirmation: password) }

    context "with valid OTP code" do
      it "signs in the user" do
        totp = ROTP::TOTP.new(user.otp_secret)
        code = totp.now

        post :verify_mfa, params: {
          user_id: user.id,
          password: password,
          otp_code: code
        }

        expect(response).to have_http_status(:ok)
        expect(parsed_response["success"]).to be true
        expect(parsed_response["data"]["user"]["email"]).to eq(user.email)
      end
    end

    context "with valid backup code" do
      before do
        user.update_column(:otp_backup_codes, ["ABCD1234", "EFGH5678"])
      end

      it "signs in the user and removes the backup code" do
        post :verify_mfa, params: {
          user_id: user.id,
          password: password,
          otp_code: "ABCD1234"
        }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["success"]).to be true
        user.reload
        expect(user.otp_backup_codes).not_to include("ABCD1234")
      end
    end

    context "with invalid OTP code" do
      it "returns an error" do
        post :verify_mfa, params: {
          user_id: user.id,
          password: password,
          otp_code: "000000"
        }

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_response["success"]).to be false
      end
    end

    context "with invalid password" do
      it "returns an error" do
        totp = ROTP::TOTP.new(user.otp_secret)
        code = totp.now

        post :verify_mfa, params: {
          user_id: user.id,
          password: "wrong_password",
          otp_code: code
        }

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_response["success"]).to be false
      end
    end

    context "with missing user" do
      it "returns an error" do
        post :verify_mfa, params: {
          user_id: "invalid-id",
          password: password,
          otp_code: "123456"
        }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET #me" do
    let(:user) { create(:user) }

    context "when authenticated" do
      before do
        sign_in user
      end

      it "returns user information" do
        get :me
        expect(response).to have_http_status(:ok)
        expect(parsed_response["success"]).to be true
        expect(parsed_response["data"]["user"]["email"]).to eq(user.email)
      end
    end

    context "when not authenticated" do
      it "returns an error" do
        get :me
        expect(response).to have_http_status(:unauthorized)
        expect(parsed_response["success"]).to be false
      end
    end
  end

  describe "DELETE #destroy" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it "signs out the user" do
      delete :destroy
      expect(response).to have_http_status(:ok)
      expect(parsed_response["success"]).to be true
    end
  end
end

