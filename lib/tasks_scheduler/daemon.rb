require 'open3'

module TasksScheduler
  class Daemon
    ACTIONS = %w(status start stop restart).freeze

    class << self
      def execute(action)
        raise "Action not allowed: #{action} (Allowed: #{ACTIONS})" unless ACTIONS.include?(action)
        command = ['bundle', 'exec', 'tasks_scheduler', action]
        env_args = { 'RAILS_ENV' => Rails.env }
        Dir.chdir(Rails.root) do
          Open3.popen3(env_args, *command) do |_stdin, stdout, stderr, wait_thr|
            { action: action, env_args: env_args.map { |k, v| "#{k}=#{v}" }.join(' | '),
              command: command.join(' '), status: wait_thr.value.to_i, stdout: stdout.read,
              stderr: stderr.read }
          end
        end
      end

      def running?
        execute('status')[:status].zero?
      end
    end
  end
end
