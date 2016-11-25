require 'rake'

class ScheduledTask < ActiveRecord::Base
  include ::ScheduledTask::Checker
  include ::ScheduledTask::Status
  include ::ScheduledTask::Runner

  class << self
    def rake_tasks
      @rake_tasks ||= begin
        Rails.application.load_tasks
        Rake.application.tasks.map(&:name)
      end
    end
  end

  validates :scheduling, presence: true, 'tasks_scheduler/cron_scheduling': true
  validates :task, presence: true, inclusion: { in: rake_tasks }

  STATUS_RUNNING = 'running'
  STATUS_FAILED = 'failed'
  STATUS_WAITING = 'waiting'

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
end
