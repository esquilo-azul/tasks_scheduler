module ScheduledTasksHelper
  def scheduled_tasks_status_time(time)
    if time.present?
      I18n.l(time, format: :short)
    else
      '-'
    end
  end
end
