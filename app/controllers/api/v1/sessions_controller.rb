# frozen_string_literal: true

module Api
  module V1
    # Controller for handling user authentication (sign in/out)
    class SessionsController < BaseController
      skip_before_action :authenticate_user!, only: [:create, :destroy, :me, :verify_mfa]

      # GET /api/v1/auth/me
      def me
        if user_signed_in?
          user = current_user
          render_success({
            user: {
              id: user.id,
              email: user.email,
              two_factor_enabled: user.two_factor_enabled?
            }
          })
        else
          render_error("Not authenticated", status: :unauthorized)
        end
      end

      # POST /api/v1/auth/sign_in
      def create
        user = User.find_by(email: params[:user][:email])

        if user&.valid_password?(params[:user][:password])
          if user.otp_required_for_login?
            render json: {
              success: false,
              requires_mfa: true,
              user_id: user.id,
              message: "MFA verification required"
            }, status: :ok
          else
            sign_in(user)
            render_success({
              user: {
                id: user.id,
                email: user.email,
                two_factor_enabled: user.two_factor_enabled?
              },
              message: "Signed in successfully"
            })
          end
        else
          render_error("Invalid email or password", status: :unauthorized)
        end
      end

      def verify_mfa
        validator = MfaVerificationValidator.new
        validation_result = validator.call(
          user_id: params[:user_id],
          password: params[:password],
          otp_code: params[:otp_code] || params[:code]
        )

        unless validation_result.success?
          return render_error(
            "Validation failed",
            status: :unprocessable_entity,
            errors: validation_result.errors.to_h
          )
        end

        user = User.find_by(id: validation_result[:user_id])

        unless user
          render_error("User not found", status: :not_found)
          return
        end

        unless user.valid_password?(validation_result[:password])
          render_error("Invalid password", status: :unauthorized)
          return
        end

        otp_code = validation_result[:otp_code]
        if user.verify_otp(otp_code)
          sign_in(user)
          render_success({
            user: {
              id: user.id,
              email: user.email,
              two_factor_enabled: user.two_factor_enabled?
            },
            message: "Signed in successfully"
          })
        elsif user.valid_backup_code?(otp_code)
          user.use_backup_code!(otp_code)
          sign_in(user)
          render_success({
            user: {
              id: user.id,
              email: user.email,
              two_factor_enabled: user.two_factor_enabled?
            },
            message: "Signed in successfully with backup code"
          })
        else
          render_error("Invalid verification code", status: :unauthorized)
        end
      end

      # DELETE /api/v1/auth/sign_out
      def destroy
        sign_out(current_user) if user_signed_in?
        render_success({ message: "Signed out successfully" })
      end
    end
  end
end

