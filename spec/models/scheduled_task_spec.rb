# frozen_string_literal: true

RSpec.describe(ScheduledTask) do
  fixtures :scheduled_tasks

  let(:instance) { scheduled_tasks(:test_scheduling) }
  let(:time) { Time.utc(2016, 12, 22, 12, 0, 0, 0) }

  describe '#scheduling' do
    {
      '0 1 * * *' => Time.utc(2016, 12, 23, 1, 0, 0, 0),
      '*/5 * * * *' => Time.utc(2016, 12, 22, 12, 5, 0, 0),
      '* * 1 * *' => Time.utc(2017, 1, 1, 0, 0, 0, 0),
      '* * * * *' => Time.utc(2016, 12, 22, 12, 1, 0, 0)
    }.each do |scheduling, expected_next_run|
      context "when sheduling is #{scheduling}" do
        before { instance.scheduling = scheduling }

        it 'is valid' do
          expect(instance.valid?).to be_truthy, instance.errors.messages.to_s
        end

        it "calculate next run as #{expected_next_run}" do
          expect(instance.calculate_next_run(time).utc).to eq(expected_next_run)
        end
      end
    end

    ['  ', nil, '1', 'abc123', 456].each do |scheduling|
      context "when sheduling is #{scheduling}" do
        before { instance.scheduling = scheduling }

        it 'is invalid' do
          expect(instance.valid?).to be_falsy, instance.errors.messages.to_s
        end
      end
    end
  end

  describe 'status' do
    it { expect(instance.last_run_start).to be_falsy }
    it { expect(instance.last_run_successful_start).to be_falsy }
    it { expect(instance.last_run_unsuccessful_start).to be_falsy }
    it { expect(instance.last_run_successful_end).to be_falsy }
    it { expect(instance.last_run_unsuccessful_end).to be_falsy }
    it { expect(instance.status).to eq(ScheduledTask::STATUS_WAITING) }

    context 'when start' do
      subject { instance.status }

      before { instance.send('status_on_start') }

      it { is_expected.to eq(ScheduledTask::STATUS_RUNNING) }

      context 'when stop' do # rubocop:disable RSpec/NestedGroups
        before { instance.send('status_on_end', nil, nil) }

        it { is_expected.to eq(ScheduledTask::STATUS_WAITING) }

        context 'when start again' do # rubocop:disable RSpec/NestedGroups
          before { instance.send('status_on_start') }

          it { is_expected.to eq(ScheduledTask::STATUS_RUNNING) }

          context 'when fail' do # rubocop:disable RSpec/NestedGroups
            before do
              instance.send('status_on_end', StandardError.new('Test!'),
                            ScheduledTask::STATUS_FAILED)
            end

            it { is_expected.to eq(ScheduledTask::STATUS_FAILED) }
          end

          context 'when abort' do # rubocop:disable RSpec/NestedGroups
            before do
              instance.send('status_on_end', StandardError.new('Test!'),
                            ScheduledTask::STATUS_ABORTED)
            end

            it { is_expected.to eq(ScheduledTask::STATUS_ABORTED) }
          end

          context 'when time out' do # rubocop:disable RSpec/NestedGroups
            before do
              instance.send('status_on_end', StandardError.new('Test!'),
                            ScheduledTask::STATUS_TIMEOUT)
            end

            it { is_expected.to eq(ScheduledTask::STATUS_TIMEOUT) }
          end
        end
      end
    end

    describe 'status 1' do
      before do
        instance.update!(
          scheduling: '*/5 * * * *',
          next_run: 'Wed, 28 Feb 2018 15:35:00 UTC +00:00',
          created_at: 'Tue, 06 Dec 2016 20:30:01 UTC +00:00',
          updated_at: 'Wed, 28 Feb 2018 15:31:34 UTC +00:00',
          last_run_start: nil,
          last_run_successful_start: 'Wed, 28 Feb 2018 15:20:06 UTC +00:00',
          last_run_successful_end: 'Wed, 28 Feb 2018 15:20:15 UTC +00:00',
          last_run_unsuccessful_start: 'Wed, 28 Feb 2018 15:30:07 UTC +00:00',
          last_run_unsuccessful_end: 'Wed, 28 Feb 2018 15:31:34 UTC +00:00',
          pid: nil,
          args: '1|1|1',
          last_fail_status: nil
        )
      end

      it do
        expect(instance.status).to eq(ScheduledTask::STATUS_FAILED)
      end
    end
  end

  describe 'task in list' do
    ['test', 'about', 'db:migrate'].each do |task|
      context "when task is #{task}" do
        before { instance.task = task }

        it { expect(instance).to be_valid }
      end
    end
    [nil, '  ', '123notatask'].each do |task|
      context "when task is #{task}" do
        before { instance.task = task }

        it { expect(instance).not_to be_valid }
      end
    end
  end

  describe '#invoke_args' do
    {
      '' => [],
      'abc' => ['abc'],
      'abc|def|ghi' => %w[abc def ghi],
      'abc||ghi' => ['abc', '', 'ghi']
    }.each do |input, expected|
      context "when args is #{input}" do
        before { instance.args = input }

        it { expect(instance.send('invoke_args')).to eq(expected) }
      end
    end
  end
end
