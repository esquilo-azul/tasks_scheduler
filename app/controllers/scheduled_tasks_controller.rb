class ScheduledTasksController < ApplicationController
  active_scaffold :scheduled_task do |conf|
    [:create, :update, :list].each do |action|
      conf.send(action).columns.exclude(:next_run, :last_run_start,
                                        :last_run_successful_start, :last_run_unsuccessful_start,
                                        :last_run_successful_end, :last_run_unsuccessful_end)
    end
    conf.columns[:task].form_ui = :select
    conf.columns[:task].options ||= {}
    conf.columns[:task].options[:options] = task_column_options
    conf.action_links.add :status, label: I18n.t(:tasks_scheduler_status), position: true
  end

  def status
  end

  def status_content
    @scheduled_tasks = ::ScheduledTask.order(task: :asc, scheduling: :asc)
    render layout: false
  end

  class << self
    private

    def task_column_options
      ::ScheduledTask.rake_tasks.map { |st| [st, st] }
    end
  end
end