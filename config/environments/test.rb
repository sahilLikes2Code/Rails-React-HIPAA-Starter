require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=3600"
  }

  config.show_deprecations = true
  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  config.action_controller.allow_forgery_protection = false
  config.action_controller.perform_caching = false
  config.action_controller.cache_store = :null_store

  config.action_dispatch.show_exceptions = :rescuable

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test

  config.active_storage.service = :test

  config.active_support.test_order = :random
  config.active_support.executor_around_test_case = :around

  config.log_level = :debug
  config.log_formatter = ::Logger::Formatter.new

  config.active_record.maintain_test_schema = true
  config.active_record.migration_error = :no_message
  config.active_record.dump_schema_after_migration = false

  config.active_job.queue_adapter = :test
end

