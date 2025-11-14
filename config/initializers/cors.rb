Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Restrict CORS to API routes only
    # In development, allow localhost (same-origin SPA doesn't need CORS, but this is for flexibility)
    # In production, use environment variable for allowed origins
    if Rails.env.production?
      origins ENV.fetch("ALLOWED_ORIGINS", "").split(",").reject(&:blank?)
      resource "/api/*",
        headers: :any,
        methods: [:get, :post, :patch, :put, :delete, :options],
        credentials: true
    else
      # Development: allow localhost origins, no credentials needed for same-origin
      origins "http://localhost:3000", "http://127.0.0.1:3000"
      resource "/api/*",
        headers: :any,
        methods: [:get, :post, :patch, :put, :delete, :options],
        credentials: false
    end
  end
end

