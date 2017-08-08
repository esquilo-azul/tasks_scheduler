class ScheduledTask < ActiveRecord::Base
  module Runner
    def run
      log_on_start
      run_banner
      return if process_running? && pid != Process.pid
      status_on_start
      exception = invoke_task
      run_log(exception, :fatal) if exception
      status_on_end(exception)
      log_on_end(exception)
      run_log("Next run: #{next_run.in_time_zone}")
    end

    private

    def run_log(message, method = :info)
      if message.is_a?(Exception)
        run_log("#{message.class}: #{message.message}")
        run_log(message.backtrace.join("\n"))
      else
        Rails.logger.send(method, "TASK_RUN(#{id}): #{message}")
      end
    end

    def run_banner
      run_log("Task: #{self}")
      run_log("PID: #{pid ? pid : '-'} (Current: #{Process.pid})")
      run_log("Process running? #{process_running? ? 'Yes' : 'No'}")
      run_log("Rails.env: #{Rails.env}")
    end

    def invoke_task
      exception = nil
      begin
        Rake::Task.clear
        Rails.application.load_tasks
        Rake::Task[task].invoke(*invoke_args)
      rescue StandardError => ex
        run_log(ex, :fatal)
        exception = ex
      end
      exception
    end

    def invoke_args
      return [] unless args.present?
      args.split('|')
    end
  end
end
