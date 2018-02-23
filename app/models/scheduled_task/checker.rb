require 'rake'

class ScheduledTask < ActiveRecord::Base
  module Checker
    def check
      check_banner
      if pid.present?
        check_on_pid_present
      else
        check_on_pid_not_present
      end
    end

    private

    def check_on_pid_present
      if process_running?
        if timeout?
          check_log('Timeout')
          on_end_running(StandardError.new("Timeout (PID: #{pid}. running time: #{running_time})"), STATUS_TIMEOUT)
        else
          check_log('Already running')
        end
      else
        check_log('Aborted')
        on_end_running(Exception.new("Aborted (PID: #{pid} not found)"), STATUS_ABORTED)
      end
    end

    def check_on_pid_not_present
      if next_run.present?
        check_task_with_next_run
      else
        check_task_without_next_run
      end
    end

    def check_log(message, method = :info)
      Rails.logger.send(method, "TASK_CHECK(#{id}): #{message}")
    end

    def check_banner
      check_log("Task: #{self}")
      check_log("PID: #{pid}")
      check_log("Running? #{process_running?}")
      check_log("Last fail status: #{last_fail_status}")
    end

    def check_task_without_next_run
      check_log('Next run blank')
      update_attributes!(next_run: calculate_next_run)
      check_log("Next run scheduled: #{next_run.in_time_zone}")
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
      update_attributes!(pid: spawn_pid, last_fail_status: nil)
    end

    def timeout?
      running_time >= ::ScheduledTask.timeout
    end

    def running_time
      last_run_start.present? ? Time.zone.now - last_run_start : 0
    end
  end
end
