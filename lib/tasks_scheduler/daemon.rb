# frozen_string_literal: true

require 'tasks_scheduler/app_gem'

module TasksScheduler
  class Daemon
    ACTIONS = %w[status start stop restart].freeze

    class << self
      def daemon_command(action)
        raise "Action not allowed: #{action} (Allowed: #{ACTIONS})" unless ACTIONS.include?(action)

        ::TasksScheduler::AppGem.instance.bundle('exec', 'tasks_scheduler', action)
                                .envvar(::TasksScheduler::Checker::LOG_ON_FILE_ENV_KEY, '1')
      end

      def execute(action)
        command = daemon_command(action)
        result = command.execute
        {
          action: action, env_args: env_args_to_s(command), command: command.to_s,
          status: result.fetch(:exit_code), stdout: result.fetch(:stdout),
          stderr: result.fetch(:stderr)
        }
      end

      def running?
        execute('status')[:status].zero?
      end

      def env_args_to_s(command)
        command.send(:extra_options).fetch(:envvars).map { |k, v| "#{k}=#{v}" }.join(' | ')
      end
    end
  end
end
