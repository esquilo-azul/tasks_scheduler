# frozen_string_literal: true

module TasksScheduler
  class Info
    TASKS_LIMIT_KEY = 'TASKS_SCHEDULER_TASKS_LIMIT'
    TASKS_LIMIT_DEFAULT_VALUE = '-1'

    class << self
      def can_run_new_task?
        return true if tasks_running_limit.negative?

        tasks_running_current < tasks_running_limit
      end

      def tasks_running_current
        ::ScheduledTask.all.select(&:process_running?).count
      end

      def tasks_running_limit
        ENV[TASKS_LIMIT_KEY].if_present(TASKS_LIMIT_DEFAULT_VALUE, &:to_i)
      end
    end
  end
end
