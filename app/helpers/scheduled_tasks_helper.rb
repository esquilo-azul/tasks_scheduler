# frozen_string_literal: true

module ScheduledTasksHelper
  def scheduled_tasks_status_time(time)
    if time.present?
      I18n.l(time, format: :short)
    else
      '-'
    end
  end

  def scheduled_tasks_log(scheduled_task, log_identifier)
    if File.exist?(scheduled_task.log_file(log_identifier))
      link_to I18n.t(:log), log_scheduled_task_path(scheduled_task, identifier: log_identifier)
    else
      '-'
    end
  end
end
