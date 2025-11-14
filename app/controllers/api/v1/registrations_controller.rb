# frozen_string_literal: true

module Api
  module V1
    # Controller for handling user registration
    class RegistrationsController < BaseController
      skip_before_action :authenticate_user!, only: [:create]

      # POST /api/v1/auth/sign_up
      def create
        user = User.new(user_params)

        if user.save
          sign_in(user)
          render_success({
            user: {
              id: user.id,
              email: user.email,
              first_name: user.first_name,
              last_name: user.last_name,
              two_factor_enabled: user.two_factor_enabled?
            },
            message: "Account created successfully"
          }, status: :created)
        else
          render_validation_errors(user)
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :phone_number, :date_of_birth)
      end
    end
  end
end

