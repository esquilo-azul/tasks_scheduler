# frozen_string_literal: true

require 'parse-cron'

module TasksScheduler
  class CronSchedulingValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return if value_valid?(value)

      record.errors.add(attribute, (options[:message] ||
          I18n.t(:cron_scheduling_validator_error_message)))
    end

    private

    def value_valid?(value)
      ::CronParser.new(value).next
      true
    rescue ArgumentError
      false
    end
  end
end
