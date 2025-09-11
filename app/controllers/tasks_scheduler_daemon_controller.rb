# frozen_string_literal: true

require 'tasks_scheduler/checker'

class TasksSchedulerDaemonController < ApplicationController
  include ::TasksSchedulerDaemonController::DownloadLog

  def index; end

  def execute
    @result = ::TasksScheduler::Daemon.execute(params[:tasks_scheduler_execute_action])
    render 'index'
  end

  def status
    render json: { daemon_running: ::TasksScheduler::Daemon.running?,
                   tasks_all_ok: ::ScheduledTask.all.none?(&:failed?) }
  end
end
