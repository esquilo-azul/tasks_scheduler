# frozen_string_literal: true

require 'tasks_scheduler/checker/log'

module TasksScheduler
  class Checker
    include Singleton

    CHECK_INTERVAL = 15
    LOG_ON_FILE_ENV_KEY = 'TASKS_SCHEDULER_LOG_ON_FILE'
    LOGS_KEYS = %w[rails stdout stderr].freeze

    def run
      check_log
      running = true
      Signal.trap('TERM') { running = false }
      while running
        Rails.logger.info('Checking all tasks...')
        ::ScheduledTask.all.each(&:check)
        Rails.logger.info("All tasks checked. Sleeping for #{CHECK_INTERVAL} second(s)...")
        sleep(CHECK_INTERVAL)
      end
    end

    def log_path
      rais_log.path
    end

    def logs
      LOGS_KEYS.map { |key| send("#{key}_log") }
    end

    LOGS_KEYS.each do |log_key|
      class_eval <<CODE, __FILE__, __LINE__ + 1
      def #{log_key}_log
        @#{log_key}_log ||= ::TasksScheduler::Checker::Log.new('#{log_key}')
      end
CODE
    end

    private

    def check_log
      return unless log_on_file?

      ::Rails.logger = ::Logger.new(rails_log.path)
      $stdout.reopen(stdout_log.path, 'w')
      $stderr.reopen(stderr_log.path, 'w')
    end

    def log_on_file?
      ENV[LOG_ON_FILE_ENV_KEY].present?
    end
  end
end
