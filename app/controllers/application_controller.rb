# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Skip CSRF for API namespace (handled by API base controller)
  # Keep CSRF for homepage (React mount point)
  protect_from_forgery with: :exception, unless: -> { request.path.start_with?("/api/") }

  # Handle Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    # For API requests, return JSON error
    if request.path.start_with?("/api/")
      render json: { success: false, error: "You are not authorized to perform this action." }, status: :forbidden
    else
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end
  end
end

