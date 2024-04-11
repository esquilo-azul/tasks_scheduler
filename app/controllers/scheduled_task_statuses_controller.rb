# frozen_string_literal: true

class ScheduledTaskStatusesController < ApplicationController
  def log
    record = find_if_allowed(params[:id], :read)
    @log_file = record.log_file(params[:identifier])
  end

  def status; end

  def status_content
    @scheduled_tasks = ::ScheduledTask.order(task: :asc, scheduling: :asc)
    render layout: false
  end
end
