class TasksSchedulerDaemonController < ApplicationController
  def index
  end

  def execute
    @result = ::TasksScheduler::Daemon.execute(params[:tasks_scheduler_execute_action])
    render 'index'
  end

  def running
    render plain: (::TasksScheduler::Daemon.running? ? 'true' : 'false'), layout: false
  end

  def download_log
    if File.exist?(::TasksScheduler::Checker.instance.log_path)
      send_log_file
    else
      redirect_to(tasks_scheduler_daemon_path,
                  notice: "Arquivo \"#{::TasksScheduler::Checker.instance.log_path}\" não existe")
    end
  end

  private

  def send_log_file
    send_file(
      ::TasksScheduler::Checker.instance.log_path,
      filename: "#{request.base_url.parameterize}_tasks-scheduler_checker-log_" \
        "#{Time.zone.now.to_s.parameterize}.log",
      type: 'text/plain'
    )
  end
end
