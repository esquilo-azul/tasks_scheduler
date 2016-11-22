class ScheduledTasksController < ApplicationController
  active_scaffold :scheduled_task do |conf|
    [:create, :update].each do |action|
      conf.send(action).columns.exclude :next_run
    end
    conf.columns[:task].form_ui = :select
    conf.columns[:task].options ||= {}
    conf.columns[:task].options[:options] = task_column_options
  end

  class << self
    private

    def task_column_options
      ::ScheduledTask.rake_tasks.map { |st| [st, st] }
    end
  end
end
