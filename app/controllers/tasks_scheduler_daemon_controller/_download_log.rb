class TasksSchedulerDaemonController < ApplicationController
  def download_log
    return unless download_log_validate_log_key
    log = ::TasksScheduler::Checker.instance.send("#{download_log_key}_log")
    return unless download_log_validate_log_exist(log)
    send_log_file(log)
  end

  private

  def download_log_key
    params[:log_key]
  end

  def download_log_validate_log_key
    return true if ::TasksScheduler::Checker::LOGS_KEYS.include?(download_log_key)
    redirect_to(tasks_scheduler_daemon_path,
                notice: "Invalid log key: \"#{download_log_key}\"")
    false
  end

  def download_log_validate_log_exist(log)
    return true if log.exist?
    redirect_to(tasks_scheduler_daemon_path, notice: "Log \"#{log.key}\" does not exist.")
    false
  end

  def send_log_file(log)
    send_file(
      log.path,
      filename: "#{request.base_url.parameterize}_tasks-scheduler_checker-log_" \
        "#{Time.zone.now.to_s.parameterize}.log",
      type: 'text/plain'
    )
  end
end
