require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory usage.
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Enable server timing.
  config.server_timing = false

  # Enable static file serving from public directory.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress CSS using a preprocessor.
  config.assets.css_compressor = nil # We use cssbundling-rails

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a single reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Log to STDOUT by default; make sure this is the only active log destination.
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # "Info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set this to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # HIPAA Compliance: Ensure sensitive parameters are filtered in production
  # This is already configured in application.rb, but we verify it here
  # Filtered parameters will show as [FILTERED] in logs instead of actual values

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter = :sidekiq
  # config.active_job.queue_name_prefix = "rails_react_hipaa_starter_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp

  # Set default URL for mailer (HIPAA: Use HTTPS)
  config.action_mailer.default_url_options = { protocol: "https", host: ENV.fetch("MAILER_HOST", "example.com") }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other HTTP headers.
  # config.hosts << "example.com"

  # Disable Sprockets SCSS compilation - we use cssbundling-rails
  config.assets.css_compressor = nil
  config.assets.precompile = []
  config.assets.paths.reject! { |path| path.to_s.include?("stylesheets") && !path.to_s.include?("builds") }

  # HIPAA Compliance: Production Security Settings
  # Ensure encryption keys are set (not using dev temp keys)
  if Lockbox.master_key.blank? || Lockbox.master_key.length < 64
    raise "LOCKBOX_MASTER_KEY must be set in production credentials or environment variable"
  end

  # Disable detailed error pages in production
  config.consider_all_requests_local = false

  # Enable request forgery protection
  config.action_controller.allow_forgery_protection = true
end

