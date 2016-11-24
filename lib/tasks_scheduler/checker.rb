module TasksScheduler
  class Checker
    include Singleton

    CHECK_INTERVAL = 15

    def run
      running = true
      Signal.trap('TERM') do
        running = false
      end
      while running
        Rails.logger.info('Checking all tasks...')
        ::ScheduledTask.all.each(&:check)
        Rails.logger.info("All tasks checked. Sleeping for #{CHECK_INTERVAL} second(s)...")
        sleep(CHECK_INTERVAL)
      end
    end
  end
end
