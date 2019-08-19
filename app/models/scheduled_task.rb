require 'rake'

class ScheduledTask < ActiveRecord::Base
  include ::ScheduledTask::Checker
  include ::ScheduledTask::Log
  include ::ScheduledTask::Runner
  include ::ScheduledTask::Status

  DEFAULT_TIMEOUT_ENVVAR_NAME = 'TASKS_SCHEDULER_TIMEOUT'.freeze
  DEFAULT_TIMEOUT = 12.hours

  class << self
    def rake_tasks
      @rake_tasks ||= begin
        Rails.application.load_tasks
        Rake.application.tasks.map(&:name)
      end
    end

    def timeout
      @timeout ||= begin
        r = Integer(ENV[DEFAULT_TIMEOUT_ENVVAR_NAME])
        r > 0 ? r.seconds : DEFAULT_TIMEOUT
      rescue ArgumentError, TypeError
        DEFAULT_TIMEOUT
      end
    end
  end

  STATUS_RUNNING = 'running'
  STATUS_FAILED = 'failed'
  STATUS_WAITING = 'waiting'
  STATUS_ABORTED = 'aborted'
  STATUS_TIMEOUT = 'timeout'
  STATUS_DISABLED = 'disabled'

  LAST_FAIL_STATUSES = [STATUS_FAILED, STATUS_ABORTED, STATUS_TIMEOUT]

  validates :scheduling, presence: true, 'tasks_scheduler/cron_scheduling': true
  validates :task, presence: true, inclusion: { in: rake_tasks }
  validates :last_fail_status, allow_blank: true, inclusion: { in: LAST_FAIL_STATUSES }

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

  def write_attribute(name, value)
    @cron_parser = nil if name == 'scheduling'
    super
  end

  def process_running?
    return false if pid.nil?
    Process.kill(0, pid)
    return true
  rescue Errno::EPERM
    raise "No permission to query #{pid}!"
  rescue Errno::ESRCH
    return false
  rescue
    raise "Unable to determine status for #{pid}"
  end

  def task_exist?
    self.class.rake_tasks.include?(task)
  end
end
