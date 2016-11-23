class ScheduledTask < ActiveRecord::Base
  module Status
    def status
      return STATUS_RUNNING if running?
      return STATUS_WAITING if waiting?
      return STATUS_FAILED if failed?
      fail "Unknown status (#{status_attributes_values})"
    end

    def running?
      last_run_start.present?
    end

    def waiting?
      return true if ended?(last_run_successful_end, last_run_unsuccessful_end)
      status_attributes.all? { |a| send(a).blank? }
    end

    def failed?
      ended?(last_run_unsuccessful_end, last_run_successful_end)
    end

    def ended?(time, oposite_time)
      !running? && time.present? && (oposite_time.blank? || oposite_time < time)
    end

    private

    def status_on_start
      update_attributes!(last_run_start: Time.zone.now)
    end

    def status_on_end(exception)
      update_attributes!(
        next_run: calculate_next_run,
        (exception ? :last_run_unsuccessful_start : :last_run_successful_start) => last_run_start,
        (exception ? :last_run_unsuccessful_end : :last_run_successful_end) => Time.zone.now,
        last_run_start: nil
      )
    end

    def status_attributes
      %w(start successful_start successful_end unsuccessful_start unsuccessful_end).map do |a|
        "last_run_#{a}"
      end
    end

    def status_attributes_values
      status_attributes.map { |a| "#{a}: #{send(a)}" }.join(', ')
    end
  end
end
