# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.before(:suite) do
    # Explicitly set Devise mapping for User model to resolve "Could not find a valid mapping" error
    # Devise.mappings[:user] = Devise::Mapping.find_by_path!("/users") # Remove this line
    Devise.mappings[:user] = Devise.add_mapping(:user, to: User)
  end

  config.before(:each, type: :controller) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  config.before(:each) do
    PaperTrail.request.whodunnit = nil
  end
end

