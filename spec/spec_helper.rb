# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

# Prevent database truncation if the environment is production
dummy_app = ::File.expand_path('../test/dummy', __dir__)
require ::File.join(dummy_app, 'config', 'environment')
ActiveRecord::Migrator.migrations_paths = [
  ::File.join(dummy_app, 'db', 'migrate')
]
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  require 'eac_ruby_gem_support/rspec'
  ::EacRubyGemSupport::Rspec.setup(::File.expand_path('..', __dir__), config)

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.fixture_path = ::File.join(::EacRubyGemSupport::Rspec.default.app_root_path, 'spec',
                                    'fixtures')
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
