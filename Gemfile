source "https://rubygems.org"

ruby "3.3.0"

gem "rails", "~> 7.1.3"

gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "jsbundling-rails"
gem "cssbundling-rails"
gem "jbuilder"
gem "redis", ">= 4.0.1"
gem "rack-attack"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false

gem "devise", "~> 4.9"
gem "rack-cors", require: "rack/cors"
gem "will_paginate", "~> 4.0"
gem "ransack"
gem "pundit", "~> 2.3"
gem "rolify"
gem "dry-validation"

# HIPAA Compliance - Critical
gem "lockbox"
gem "paper_trail"
gem "devise-two-factor"
gem "rotp"
gem "rqrcode"
gem "secure_headers"

# HIPAA Compliance - Security Scanning
gem "brakeman", require: false
gem "bundler-audit", require: false

# Background Jobs
gem "sidekiq"
gem "whenever", require: false

# Additional Security
gem "strip_attributes"
gem "email_validator"

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "factory_bot_rails"

  group :rubocop do
    gem "rubocop", ">= 1.25.1", require: false
    gem "rubocop-minitest", require: false
    gem "rubocop-packaging", require: false
    gem "rubocop-performance", require: false
    gem "rubocop-rails", require: false
    gem "rubocop-md", require: false
    gem "erb_lint", require: false
    gem "htmlbeautifier", require: false
  end

  gem "rspec-rails", "~> 6.1.0"
  gem "faker"
end

group :development do
  gem "web-console"
  gem "letter_opener"
  gem "letter_opener_web", "~> 2.0"
end

