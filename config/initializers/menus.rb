# frozen_string_literal: true

require 'eac_rails_utils/patches/application'

::Rails.application.root_menu.group(:admin).group(:tasks_scheduler).within do |g|
  g.action :tasks_scheduler_daemon
  g.action :scheduled_tasks
  g.action :status_scheduled_tasks
end
