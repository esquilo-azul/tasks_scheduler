module TasksScheduler
  class Checker
    include Singleton

    CHECK_INTERVAL = 15

    def run
      loop do
        Rails.logger.info('Checking all tasks...')
        ::ScheduledTask.all.each(&:check)
        Rails.logger.info("All tasks checked. Sleeping for #{CHECK_INTERVAL} second(s)...")
        sleep(CHECK_INTERVAL)
      end
    end
  end
end
