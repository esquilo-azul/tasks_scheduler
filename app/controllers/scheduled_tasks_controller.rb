# frozen_string_literal: true

class ScheduledTasksController < ApplicationController
  class << self
    private

    def task_column_options
      ::ScheduledTask.rake_tasks.map { |st| [st, st] }
    end
  end

  before_action :localize_active_scaffold

  active_scaffold :scheduled_task do |conf|
    %i[create update list].each do |action|
      conf.send(action).columns.exclude(:next_run, :last_fail_status, :last_run_start,
                                        :last_run_successful_start, :last_run_unsuccessful_start,
                                        :last_run_successful_end, :last_run_unsuccessful_end,
                                        :pid)
    end
    conf.columns[:task].form_ui = :select
    conf.columns[:task].options ||= {}
    conf.columns[:task].options[:options] = task_column_options
    conf.action_links.add :run_now, label: :run_now, type: :member,
                                    crud_type: :update, method: :put, position: false
  end

  def run_now
    process_action_link_action do |record|
      record.update!(next_run: Time.zone.now)
      record.reload
      flash.now[:info] = "Next run adjusted to #{record.next_run}"
    end
  end

  private

  def localize_active_scaffold
    active_scaffold_config.action_links[:run_now].label = ::I18n.t(:run_now)
  end
end
