# frozen_string_literal: true

Rails.application.root_menu.group(:admin).group(:tasks_scheduler).within do |g|
  g.action :tasks_scheduler_daemon
  g.action :scheduled_tasks
  g.action :scheduled_task_statuses
end
