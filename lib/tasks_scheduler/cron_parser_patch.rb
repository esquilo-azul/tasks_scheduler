# frozen_string_literal: true

require 'parse-cron'

module TasksScheduler
  module CronParserPatch
    class TasksSchedulerTimeSource
      class << self
        def local(year, month, day, hour, min, second) # rubocop:disable Metrics/ParameterLists
          Time.utc(year, month, day, hour, min, second)
        end

        def now
          Time.now.utc
        end
      end
    end

    def self.included(base)
      base.class_eval do
        def self.new(source, time_source = TasksSchedulerTimeSource)
          super
        end
      end
    end
  end
end

unless CronParser.included_modules.include?(TasksScheduler::CronParserPatch)
  CronParser.include(TasksScheduler::CronParserPatch)
end
