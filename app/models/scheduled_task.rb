require 'rake'

class ScheduledTask < ActiveRecord::Base
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

  def cron_parser
    @cron_parser ||= ::CronParser.new(scheduling)
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
end
