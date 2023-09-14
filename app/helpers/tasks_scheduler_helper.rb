# frozen_string_literal: true

module TasksSchedulerHelper
  NAVBAR_ENTRIES = {
    tasks_scheduler_daemon: 'tasks_scheduler_daemon',
    scheduled_tasks: 'scheduled_tasks',
    tasks_scheduler_status: :status_scheduled_tasks
  }.freeze

  def tasks_scheduler_navbar
    tag.navbar do
      safe_join(tasks_scheduler_navbar_entries.map { |label, path| link_to label, path }, ' | ')
    end
  end

  def tasks_scheduler_navbar_entries
    NAVBAR_ENTRIES
      .map { |i18n_key, path_name| [::I18n.t(i18n_key), send("#{path_name}_path")] }
      .to_h
  end
end
