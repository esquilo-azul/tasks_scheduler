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
      FileUtils.mkdir_p(File.dirname(log_file(LOG_RUNNING)))
      File.unlink(log_file(LOG_RUNNING)) if File.exist?(log_file(LOG_RUNNING))
      Rails.logger = ActiveSupport::Logger.new(log_file(LOG_RUNNING))
    end

    def log_on_end(exception)
      target_log = exception ? log_file(LOG_UNSUCCESSFUL) : log_file(LOG_SUCCESSFUL)
      File.unlink(target_log) if File.exist?(target_log)
      File.rename(log_file(LOG_RUNNING), target_log)
    end
  end
end
