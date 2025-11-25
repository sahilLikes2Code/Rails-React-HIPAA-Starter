# frozen_string_literal: true

module Api
  module V1
    # Controller for handling user authentication (sign in/out)
    class SessionsController < BaseController
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
        email = params.dig(:user, :email) || params[:email]
        password = params.dig(:user, :password) || params[:password]

        unless email && password
          return render_error("Email and password are required", status: :bad_request)
        end

        user = User.find_by(email: email)

        unless user && user.valid_password?(password)
          # HIPAA/SOC2: Log failed authentication attempts
          Compliance::AuditLogger.log(
            event_type: "authentication.failed",
            actor: email,
            resource: "User",
            metadata: { reason: "invalid_credentials", ip_address: request.remote_ip }
          )
          return render_error("Invalid email or password", status: :unauthorized)
        end

        if user.otp_required_for_login?
          # HIPAA/SOC2: Log MFA requirement
          Compliance::AuditLogger.log(
            event_type: "authentication.mfa_required",
            actor: user.id.to_s,
            resource: "User",
            metadata: { email: email, ip_address: request.remote_ip }
          )
          render json: {
            success: false,
            requires_mfa: true,
            user_id: user.id,
            message: "MFA verification required"
          }, status: :ok
        else
          sign_in(resource_name, user)
          # HIPAA/SOC2: Log successful authentication
          Compliance::AuditLogger.log(
            event_type: "authentication.success",
            actor: user.id.to_s,
            resource: "User",
            metadata: { email: email, mfa_enabled: false, ip_address: request.remote_ip }
          )
          render_success({
            user: {
              id: user.id,
              email: user.email,
              two_factor_enabled: user.two_factor_enabled?
            },
            message: "Signed in successfully"
          })
        end
      rescue => e # Generic error for other unexpected issues
        Rails.logger.error("Unhandled authentication error: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        # HIPAA/SOC2: Log authentication errors
        Compliance::AuditLogger.log(
          event_type: "authentication.error",
          actor: "system",
          resource: "User",
          metadata: { error: e.class.name, message: e.message, ip_address: request.remote_ip }
        )
        render_error("An unexpected error occurred during authentication.", status: :internal_server_error)
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
          # HIPAA/SOC2: Log failed MFA password validation
          Compliance::AuditLogger.log(
            event_type: "authentication.mfa_failed",
            actor: user.id.to_s,
            resource: "User",
            metadata: { reason: "invalid_password", ip_address: request.remote_ip }
          )
          render_error("Invalid password", status: :unauthorized)
          return
        end

        otp_code = validation_result[:otp_code]
        if user.verify_otp(otp_code)
          sign_in(user)
          # HIPAA/SOC2: Log successful MFA authentication with OTP
          Compliance::AuditLogger.log(
            event_type: "authentication.mfa_success",
            actor: user.id.to_s,
            resource: "User",
            metadata: { method: "otp", ip_address: request.remote_ip }
          )
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
          # HIPAA/SOC2: Log successful MFA authentication with backup code
          Compliance::AuditLogger.log(
            event_type: "authentication.mfa_success",
            actor: user.id.to_s,
            resource: "User",
            metadata: { method: "backup_code", ip_address: request.remote_ip }
          )
          render_success({
            user: {
              id: user.id,
              email: user.email,
              two_factor_enabled: user.two_factor_enabled?
            },
            message: "Signed in successfully with backup code"
          })
        else
          # HIPAA/SOC2: Log failed MFA attempt
          Compliance::AuditLogger.log(
            event_type: "authentication.mfa_failed",
            actor: user.id.to_s,
            resource: "User",
            metadata: { reason: "invalid_code", ip_address: request.remote_ip }
          )
          render_error("Invalid verification code", status: :unauthorized)
        end
      end

      # DELETE /api/v1/auth/sign_out
      def destroy
        sign_out(current_user) if user_signed_in?
        render_success({ message: "Signed out successfully" })
      end

      private

      def auth_options
        { scope: resource_name, recall: "#{controller_path}#new" }
      end

      def resource_name
        :user
      end

      def devise_parameter_sanitizer
        # Devise usually handles this. If needed for custom fields, define here.
        # For basic login, Devise handles email and password automatically.
        super || Devise::ParameterSanitizer.new(User, :user, params)
      end
    end
  end
end

