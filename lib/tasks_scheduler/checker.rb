module TasksScheduler
  class Checker
    include Singleton

    CHECK_INTERVAL = 15
    LOG_ON_FILE_ENV_KEY = 'TASKS_SCHEDULER_LOG_ON_FILE'.freeze

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

    private

    def check_log
      return unless log_on_file?
      ::FileUtils.mkdir_p(File.dirname(log_path))
      ::Rails.logger = ::Logger.new(log_path)
    end

    def log_on_file?
      ENV[LOG_ON_FILE_ENV_KEY].present?
    end

    def log_path
      ::Rails.root.join('log', 'tasks_scheduler', 'checker.log')
    end
  end
end
