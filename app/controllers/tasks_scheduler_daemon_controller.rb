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
end
