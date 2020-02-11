# frozen_string_literal: true

class ScheduledTask < ActiveRecord::Base
  module Runner
    def run
      log_on_start
      run_banner
      return if process_running? && pid != Process.pid

      status_on_start
      exception = invoke_task
      on_end_running(exception, STATUS_FAILED)
    end

    private

    def on_end_running(exception, last_fail_status)
      run_log(exception, :fatal) if exception
      status_on_end(exception, last_fail_status)
      log_on_end(exception)
      run_log("Next run: #{next_run.in_time_zone}")
    end

    def run_log(message, method = :info)
      if message.is_a?(Exception)
        run_log("#{message.class}: #{message.message}")
        if message.backtrace.present?
          run_log(message.backtrace.join("\n"))
        else
          run_log('No backtrace present')
        end
      else
        Rails.logger.send(method, "TASK_RUN(#{id}): #{message}")
      end
    end

    def run_banner
      run_log("Task: #{self}")
      run_log("PID: #{pid || '-'} (Current: #{Process.pid})")
      run_log("Process running? #{process_running? ? 'Yes' : 'No'}")
      run_log("Rails.env: #{Rails.env}")
    end

    def invoke_task
      exception = nil
      begin
        Rake::Task.clear
        Rails.application.load_tasks
        Rake::Task[task].invoke(*invoke_args)
      rescue StandardError => e
        run_log(e, :fatal)
        exception = e
      end
      exception
    end

    def invoke_args
      return [] if args.blank?

      args.split('|')
    end
  end
end
