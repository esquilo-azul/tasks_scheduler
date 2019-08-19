class ScheduledTask < ActiveRecord::Base
  module Log
    def log_file(identifier)
      unless log_identifiers.include?(identifier)
        fail "Log identifier unknown: \"#{identifier}\" (Valid: #{log_identifiers})"
      end
      Rails.root.join('log', 'tasks_scheduler', "#{id}_#{identifier}.log")
    end

    private

    def log_identifiers
      [LOG_RUNNING, LOG_UNSUCCESSFUL, LOG_SUCCESSFUL]
    end

    def log_on_start
      log_file = log_file(LOG_RUNNING)
      FileUtils.mkdir_p(File.dirname(log_file))
      File.unlink(log_file) if File.exist?(log_file)
      STDOUT.reopen(log_file, 'w')
      STDERR.reopen(log_file, 'w')
      Rails.logger = ActiveSupport::Logger.new(STDOUT)
    end

    def log_on_end(exception)
      running_log = log_file(LOG_RUNNING)
      if ::File.exist?(running_log)
        target_log = exception ? log_file(LOG_UNSUCCESSFUL) : log_file(LOG_SUCCESSFUL)
        File.unlink(target_log) if File.exist?(target_log)
        File.rename(running_log, target_log)
      end
    end
  end
end
