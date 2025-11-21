# frozen_string_literal: true

module Api
  module V1
    # Controller for MFA setup (HIPAA Compliance)
    # JSON-only API endpoint for two-factor authentication
    class TwoFactorSetupController < BaseController
      # GET /api/v1/users/two_factor_setup/new
      def new
        current_user.reload

        # Generate secret if missing, but don't regenerate if one exists
        current_user.generate_two_factor_secret! unless current_user.otp_secret.present?
        current_user.reload

        qr_svg = current_user.qr_code_svg
        if qr_svg
          render_success({
            qr_code_url: "data:image/svg+xml;base64,#{Base64.strict_encode64(qr_svg)}"
          })
        else
          render_error("Failed to generate QR code", status: :unprocessable_entity)
        end
      end

      # POST /api/v1/users/two_factor_setup
      def create
        # Reload to get latest OTP secret, but be careful with encrypted fields
        current_user.reload

        # CRITICAL: Do NOT regenerate the secret here!
        if current_user.otp_secret.blank?
          render_error("No OTP secret found. Please visit the MFA setup page first to generate a QR code.", status: :bad_request)
          return
        end

        otp_code = params[:otp_attempt] || params[:code]

        if otp_code.blank?
          render_error("Please enter a verification code.", status: :unprocessable_entity)
          return
        end

        if current_user.verify_otp(otp_code)
          backup_codes = current_user.generate_backup_codes!
          # Use update_column to bypass validations (we're only updating otp_required_for_login)
          # This avoids issues with encrypted field validations after reload
          current_user.update_column(:otp_required_for_login, true)
          render_success({
            message: "Two-factor authentication enabled successfully",
            two_factor_enabled: true,
            backup_codes: backup_codes
          })
        else
          render_error("Invalid verification code. Please try again. Make sure you're entering the current 6-digit code from your authenticator app.", status: :unprocessable_entity)
        end
      end

      # DELETE /api/v1/users/two_factor_setup
      def destroy
        # Use update_columns to bypass validations (we're only updating MFA fields)
        # This avoids issues with encrypted field validations
        current_user.update_columns(
          otp_required_for_login: false,
          otp_secret: nil,
          otp_backup_codes: []
        )
        render_success({
          message: "Two-factor authentication disabled",
          two_factor_enabled: false
        })
      end

      # GET /api/v1/users/two_factor_setup/backup_codes
      def backup_codes
        backup_codes = current_user.otp_backup_codes || []
        render_success({
          backup_codes: backup_codes
        })
      end
    end
  end
end

