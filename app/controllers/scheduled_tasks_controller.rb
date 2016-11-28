class ScheduledTasksController < ApplicationController
  active_scaffold :scheduled_task do |conf|
    [:create, :update, :list].each do |action|
      conf.send(action).columns.exclude(:next_run, :last_run_start,
                                        :last_run_successful_start, :last_run_unsuccessful_start,
                                        :last_run_successful_end, :last_run_unsuccessful_end,
                                        :pid)
    end
    conf.columns[:task].form_ui = :select
    conf.columns[:task].options ||= {}
    conf.columns[:task].options[:options] = task_column_options
    conf.action_links.add :status, label: I18n.t(:tasks_scheduler_status), position: true
    conf.action_links.add :run_now, label: I18n.t(:run_now), type: :member,
                                    crud_type: :update, method: :put, position: false
  end

  def log
    record = find_if_allowed(params[:id], :read)
    @log_file = record.log_file(params[:identifier])
  end

  def status
  end

  def status_content
    @scheduled_tasks = ::ScheduledTask.order(task: :asc, scheduling: :asc)
    render layout: false
  end

  def run_now
    process_action_link_action do |record|
      record.update_attributes!(next_run: Time.zone.now)
      record.reload
      flash[:info] = "Next run adjusted to #{record.next_run}"
    end
  end

  class << self
    private

    def task_column_options
      ::ScheduledTask.rake_tasks.map { |st| [st, st] }
    end
  end
end
