# frozen_string_literal: true

require 'rake'
require 'eac_ruby_utils/ruby'

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
        check_on_process_running
      else
        check_log('Aborted')
        on_end_running(Exception.new("Aborted (PID: #{pid} not found)"), STATUS_ABORTED)
      end
    end

    def check_on_process_running
      if timeout?
        check_log('Timeout')
        on_end_running(StandardError.new("Timeout (PID: #{pid}. running time: #{running_time})"),
                       STATUS_TIMEOUT)
      else
        check_log('Already running')
      end
    end

    def check_on_pid_not_present
      return unless enabled?

      if next_run.present?
        check_task_with_next_run
      else
        check_task_without_next_run
      end
    end

    def check_on_task_not_exist
      message = "Task does not exist: #{task}"
      check_log(message)
      on_end_running(::StandardError.new(message), STATUS_TASK_NOT_FOUND)
    end

    def check_log(message, method = :info)
      Rails.logger.send(method, "TASK_CHECK(#{id}): #{message}")
    end

    def check_banner
      check_log("Task: #{self}")
      check_log("PID: #{pid}")
      check_log("Running? #{process_running?}")
      check_log("Last fail status: #{last_fail_status}")
      check_log("Enabled: #{enabled?}")
    end

    def check_task_without_next_run
      check_log('Next run blank')
      update!(next_run: calculate_next_run)
      check_log("Next run scheduled: #{next_run.in_time_zone}")
    end

    def check_task_with_next_run
      if !task_exist?
        check_on_task_not_exist
      elsif next_run < Time.zone.now
        check_log('Next run reached. Running...')
        spawn_task
      else
        check_log('Next run not reached')
      end
    end

    def spawn_task
      params = ['bundle', 'exec', 'tasks_scheduler_run_task', id.to_s]
      check_log("Spawn command: #{params} (Task: #{task})")
      spawn_pid = nil
      ::EacRubyUtils::Ruby.on_clean_environment do
        Dir.chdir(Rails.root) do
          spawn_pid = ::Process.spawn(*params)
        end
      end
      Process.detach(spawn_pid)
      update!(pid: spawn_pid, last_fail_status: nil)
    end

    def timeout?
      running_time >= ::ScheduledTask.timeout
    end

    def running_time
      last_run_start.present? ? Time.zone.now - last_run_start : 0
    end
  end
end
