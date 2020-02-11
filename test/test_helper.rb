# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../test/dummy/config/environment.rb', __dir__)
ActiveRecord::Migrator.migrations_paths = [
  File.expand_path('../test/dummy/db/migrate', __dir__)
]
require 'rails/test_help'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('fixtures', __dir__)
  ActiveSupport::TestCase.fixtures :all
end

module ActiveSupport
  class TestCase
    def valid_invalid_column_values_test(record, column, valid_values, invalid_values)
      valid_values.each do |v|
        record[column] = v
        assert record.valid?, "#{record.errors.messages}, #{column} = #{v.inspect} should be valid"
      end
      invalid_values.each do |v|
        record[column] = v
        assert_not record.valid?, "#{column} = #{v.inspect} should be invalid"
      end
    end
  end
end
