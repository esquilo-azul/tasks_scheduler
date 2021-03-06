# frozen_string_literal: true

module TasksScheduler
  class CronSchedulingValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return if value_valid?(value)

      record.errors[attribute] << (options[:message] ||
          I18n.translate(:cron_scheduling_validator_error_message))
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
