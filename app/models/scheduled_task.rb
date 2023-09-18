# frozen_string_literal: true

require 'eac_ruby_utils/core_ext'
require 'rake'

class ScheduledTask < ActiveRecord::Base
  include ::ScheduledTask::Checker
  include ::ScheduledTask::Log
  include ::ScheduledTask::Runner
  include ::ScheduledTask::Status

  DEFAULT_TIMEOUT_ENVVAR_NAME = 'TASKS_SCHEDULER_TIMEOUT'
  DEFAULT_TIMEOUT = 12.hours

  class << self
    def rake_tasks
      @rake_tasks ||= begin
        Rails.application.load_tasks if Rake.application.tasks.empty?
        Rake.application.tasks.map(&:name)
      end
    end

    def timeout
      @timeout ||= begin
        r = Integer(ENV[DEFAULT_TIMEOUT_ENVVAR_NAME])
        r.positive? ? r.seconds : DEFAULT_TIMEOUT
                   rescue ArgumentError, TypeError
                     DEFAULT_TIMEOUT
      end
    end
  end

  enable_listable
  lists.add_string :status, 'aborted', 'disabled', 'failed', 'running', 'task_not_found', 'timeout',
                   'waiting'

  LAST_FAIL_STATUSES = [STATUS_FAILED, STATUS_ABORTED, STATUS_TASK_NOT_FOUND, STATUS_TIMEOUT].freeze

  validates :scheduling, presence: true, 'tasks_scheduler/cron_scheduling': true
  validates :task, presence: true
  validates :last_fail_status, allow_blank: true, inclusion: { in: LAST_FAIL_STATUSES }

  validate :validate_task

  LOG_RUNNING = 'running'
  LOG_SUCCESSFUL = 'successful'
  LOG_UNSUCCESSFUL = 'unsuccessful'

  def cron_parser
    @cron_parser ||= ::CronParser.new(scheduling)
  end

  def to_s
    "S: #{scheduling}, T: #{task}, NR: #{next_run.present? ? next_run.in_time_zone : '-'}"
  end

  def calculate_next_run(time = nil)
    if time.present?
      cron_parser.next(time.utc)
    else
      cron_parser.next
    end
  end

  def _write_attribute(name, value)
    @cron_parser = nil if name == 'scheduling'
    super
  end

  def process_running?
    return false if pid.nil?

    Process.kill(0, pid)
    true
  rescue Errno::EPERM
    raise "No permission to query #{pid}!"
  rescue Errno::ESRCH
    false
  rescue StandardError
    raise "Unable to determine status for #{pid}"
  end

  def task_exist?
    self.class.rake_tasks.include?(task)
  end

  def validate_task
    return if task.blank?
    return unless task_changed?
    return if self.class.rake_tasks.include?(task)

    errors.add(:task, "Task \"#{task}\" not found")
  end
end
