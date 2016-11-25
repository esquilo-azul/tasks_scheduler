require 'rake'

class ScheduledTask < ActiveRecord::Base
  module Checker
    def check
      check_banner
      if process_running?
        check_log("Already running (PID: #{pid})")
        return
      end
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
        spawn_task
      else
        check_log('Next run not reached')
      end
    end

    def spawn_task
      params = ['bundle', 'exec', 'tasks_scheduler_run_task', id.to_s]
      check_log("Spawn command: #{params}")
      spawn_pid = nil
      Dir.chdir(Rails.root) do
        spawn_pid = Process.spawn(*params)
      end
      Process.detach(spawn_pid)
      update_attributes!(pid: spawn_pid)
    end
  end
end
