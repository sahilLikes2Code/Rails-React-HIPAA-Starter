# frozen_string_literal: true

# Base controller for all API endpoints
# Handles authentication, CSRF, and standardized JSON responses
module Api
  module V1
    class BaseController < ApplicationController
      include ApiResponders

      # Skip CSRF verification for API endpoints (handled by React with CSRF token)
      skip_before_action :verify_authenticity_token

      # Require authentication for all API endpoints
      before_action :authenticate_user!

      # Handle Pundit authorization errors with JSON response
      rescue_from Pundit::NotAuthorizedError do |e|
        render_error("You are not authorized to perform this action.", status: :forbidden)
      end

      # Handle ActiveRecord not found errors
      rescue_from ActiveRecord::RecordNotFound do |e|
        render_error("Record not found", status: :not_found)
      end
    end
  end
end

