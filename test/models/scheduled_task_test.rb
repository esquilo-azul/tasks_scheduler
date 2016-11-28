require 'test_helper'

class ScheduledTaskTest < ActiveSupport::TestCase
  SCHEDULING_VALID_VALUES = {
    '0 1 * * *' => Time.utc(2016, 12, 23, 1, 0, 0, 0),
    '*/5 * * * *' => Time.utc(2016, 12, 22, 12, 5, 0, 0),
    '* * 1 * *' => Time.utc(2017, 1, 1, 0, 0, 0, 0),
    '* * * * *' => Time.utc(2016, 12, 22, 12, 1, 0, 0)
  }

  SCHEDULING_INVALID_VALUES = ['  ', nil, '1', 'abc123', 456]

  setup do
    @scheduled_task = scheduled_tasks(:test_scheduling)
    @time = Time.utc(2016, 12, 22, 12, 0, 0, 0)
  end

  test 'scheduling cron format' do
    valid_invalid_column_values_test(
      @scheduled_task, :scheduling, SCHEDULING_VALID_VALUES.keys, SCHEDULING_INVALID_VALUES
    )
  end

  test 'calculate next run' do
    SCHEDULING_VALID_VALUES.each do |k, v|
      @scheduled_task.scheduling = k
      assert_equal v, @scheduled_task.calculate_next_run(@time).utc,
                   "Time: #{@time}, Cron source: #{k}"
    end
  end

  test 'status' do
    assert_not @scheduled_task.last_run_start
    assert_not @scheduled_task.last_run_successful_start
    assert_not @scheduled_task.last_run_unsuccessful_start
    assert_not @scheduled_task.last_run_successful_end
    assert_not @scheduled_task.last_run_unsuccessful_end
    assert_equal ScheduledTask::STATUS_WAITING, @scheduled_task.status

    @scheduled_task.send('status_on_start')
    assert_equal ScheduledTask::STATUS_RUNNING, @scheduled_task.status

    @scheduled_task.send('status_on_end', nil)
    assert_equal ScheduledTask::STATUS_WAITING, @scheduled_task.status

    @scheduled_task.send('status_on_start')
    assert_equal ScheduledTask::STATUS_RUNNING, @scheduled_task.status

    @scheduled_task.send('status_on_end', StandardError.new('Test!'))
    assert_equal ScheduledTask::STATUS_FAILED, @scheduled_task.status
  end

  test 'task in list' do
    valid_invalid_column_values_test(
      @scheduled_task, :task, ['test', 'about', 'db:migrate'], [nil, '  ', '123notatask']
    )
  end

  test 'invoke args' do
    @scheduled_task.args = ''
    assert_equal [], @scheduled_task.send('invoke_args')

    @scheduled_task.args = 'abc'
    assert_equal ['abc'], @scheduled_task.send('invoke_args')

    @scheduled_task.args = 'abc|def|ghi'
    assert_equal %w(abc def ghi), @scheduled_task.send('invoke_args')

    @scheduled_task.args = 'abc||ghi'
    assert_equal ['abc', '', 'ghi'], @scheduled_task.send('invoke_args')
  end
end
