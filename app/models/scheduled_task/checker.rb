require 'rake'

class ScheduledTask < ActiveRecord::Base
  module Checker
    def check
      check_banner
      if next_run.present?
        check_task_with_next_run
      else
        check_task_without_next_run
      end
    end

    private

    def check_log(message, method = :info)
      Rails.logger.send(method, "TASK_CHECK(#{id}): #{message}")
    end

    def check_banner
      check_log("Task: #{self}")
    end

    def check_task_without_next_run
      check_log('Next run blank')
      update_attributes!(next_run: calculate_next_run)
      check_log("Next run @scheduled_taskored: #{next_run.in_time_zone}")
    end

    def check_task_with_next_run
      if next_run < Time.zone.now
        check_log('Next run reached. Running...')
        run_task
      else
        check_log('Next run not reached')
      end
    end

    def run_task
      update_attributes!(last_run_start: Time.zone.now)
      invoke_task
      on_run_task_end
    end

    def invoke_task
      Rake::Task.clear
      Rails.application.load_tasks
      Rake::Task[task].invoke
    rescue StandardError => ex
      check_log(ex, :fatal)
    end

    def on_run_task_end
      update_attributes!(next_run: calculate_next_run)
      check_log("Next run: #{next_run.in_time_zone}")
    end
  end
end
