# frozen_string_literal: true

# Concern for standardizing API JSON responses
module ApiResponders
  extend ActiveSupport::Concern

  # Render a successful JSON response
  def render_success(data, status: :ok)
    render json: { success: true, data: data }, status: status
  end

  # Render an error JSON response
  def render_error(message, status: :unprocessable_entity, errors: nil)
    response = { success: false, error: message }
    response[:errors] = errors if errors.present?
    render json: response, status: status
  end

  # Render validation errors from ActiveModel
  def render_validation_errors(record)
    render_error(
      "Validation failed",
      status: :unprocessable_entity,
      errors: record.errors.full_messages
    )
  end
end

