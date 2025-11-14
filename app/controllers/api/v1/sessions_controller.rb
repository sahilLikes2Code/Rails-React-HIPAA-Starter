# frozen_string_literal: true

module Api
  module V1
    # Controller for handling user authentication (sign in/out)
    class SessionsController < BaseController
      skip_before_action :authenticate_user!, only: [:create, :destroy, :me]

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
          sign_in(user)
          render_success({
            user: {
              id: user.id,
              email: user.email,
              two_factor_enabled: user.two_factor_enabled?
            },
            message: "Signed in successfully"
          })
        else
          render_error("Invalid email or password", status: :unauthorized)
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

