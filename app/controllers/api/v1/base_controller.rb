# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include ApiResponders

      # Only skip CSRF verification if the callback is defined for this controller.
      # Some test/load orders may evaluate this class before the callback is defined
      # which raises an ArgumentError. Guard to avoid load-time errors.
      begin
        if _process_action_callbacks.any? { |c| c.filter == :verify_authenticity_token }
          skip_before_action :verify_authenticity_token
        end
      rescue StandardError
        # If callbacks are not available yet (load order in tests), silently continue.
      end
      # before_action :authenticate_user! # Removed for explicit handling in SessionsController
      before_action :enforce_mfa_for_phi_access, unless: -> { controller_name == "sessions" && action_name == "create" }

      rescue_from Pundit::NotAuthorizedError do |e|
        Rails.logger.warn("Authorization failed: #{e.message} - User: #{current_user&.id}")
        render_error("You are not authorized to perform this action.", status: :forbidden)
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        Rails.logger.warn("Record not found: #{e.message}")
        render_error("Record not found", status: :not_found)
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        Rails.logger.warn("Validation failed: #{e.record.class.name} - #{e.record.errors.full_messages.join(', ')}")
        render_validation_errors(e.record)
      end

      rescue_from ActionController::ParameterMissing do |e|
        Rails.logger.warn("Missing parameter: #{e.param}")
        render_error("Missing required parameter: #{e.param}", status: :bad_request)
      end

      rescue_from Lockbox::DecryptionError do |e|
        Rails.logger.error("Decryption error: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
        render_error("Data decryption error. Please contact support if this persists.", status: :internal_server_error)
      end

      # Dry::Validation may not define MissingKeyError in all versions. Only add
      # the rescue handler if the constant exists to avoid load-time NameError.
      if defined?(Dry::Validation::MissingKeyError)
        rescue_from Dry::Validation::MissingKeyError do |e|
          Rails.logger.warn("Validation missing key: #{e.message}")
          render_error("Validation error: Missing required field", status: :bad_request)
        end
      end

      rescue_from StandardError do |e|
        Rails.logger.error("Unhandled error in #{self.class.name}: #{e.class}: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        
        # Don't expose internal error details in production
        error_message = Rails.env.production? ? "An unexpected error occurred" : "#{e.class}: #{e.message}"
        render_error(error_message, status: :internal_server_error)
      end

      private

      def enforce_mfa_for_phi_access
        return unless user_signed_in?
        return if current_user.two_factor_enabled?

        phi_accessing_actions = %w[show update create destroy index]
        phi_controllers = %w[users registrations]

        if phi_controllers.include?(controller_name) &&
           phi_accessing_actions.include?(action_name)
          render_error(
            "Multi-factor authentication is required to access protected health information",
            status: :forbidden
          )
        end
      end
    end
  end
end

