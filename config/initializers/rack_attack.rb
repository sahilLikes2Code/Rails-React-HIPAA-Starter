# frozen_string_literal: true

# Rack::Attack configuration for rate limiting
# Configure rate limits for HIPAA compliance and security

class Rack::Attack
  # Configure Redis for rate limiting (use memory store in development)
  if Rails.env.development?
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  else
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
  end

  # Skip rate limiting in development and test
  if Rails.env.development? || Rails.env.test?
    # Allow all requests in development/test
    # Comment out the throttles below if you want to test rate limiting
  else
    # Throttle login attempts (production only)
    throttle("logins/email", limit: 5, period: 20.minutes) do |req|
      if req.path == "/users/sign_in" && req.post?
        req.params["user"]&.dig("email")&.to_s&.downcase&.gsub(/\s+/, "")
      end
    end

    # Throttle signup attempts (production only)
    throttle("registrations/ip", limit: 3, period: 1.hour) do |req|
      req.ip if req.path == "/users" && req.post?
    end

    # Throttle password reset requests (production only)
    throttle("password_resets/email", limit: 5, period: 1.hour) do |req|
      if req.path == "/users/password" && req.post?
        req.params["user"]&.dig("email")&.to_s&.downcase&.gsub(/\s+/, "")
      end
    end

    # Throttle all requests by IP (production only)
    throttle("req/ip", limit: 300, period: 5.minutes) do |req|
      req.ip
    end
  end

  # Customize response for throttled requests
  # Use throttled_responder instead of deprecated throttled_response
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"] || {}
    retry_after = match_data[:period] || 60

    if defined?(Compliance::AuditLogger)
      Compliance::AuditLogger.log(
        event_type: "rack_attack.block",
        actor: request.ip,
        resource: request.path,
        metadata: {
          limiter: request.env["rack.attack.matched"] || "unknown",
          limit: match_data[:limit],
          period: match_data[:period],
          discriminator: match_data[:discriminator]
        }.compact
      )
    end

    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [{ error: "Rate limit exceeded. Please try again later." }.to_json]
    ]
  end
end

