# frozen_string_literal: true

module Api
  module V1
    # Controller for handling user registration
    class RegistrationsController < BaseController
      skip_before_action :authenticate_user!, only: [:create]

      def create
        validator = UserParamsValidator.new
        validation_result = validator.call(user_params.to_h)

        unless validation_result.success?
          return render_error(
            "Validation failed",
            status: :unprocessable_entity,
            errors: validation_result.errors.to_h
          )
        end

        validated_params = validation_result.to_h
        validated_params[:date_of_birth] = Date.parse(validated_params[:date_of_birth]) if validated_params[:date_of_birth]

        user = User.new(validated_params)

        if user.save
          sign_in(user)
          render_success({
            user: {
              id: user.id,
              email: user.email,
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

