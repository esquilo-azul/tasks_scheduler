require 'open3'

module TasksScheduler
  class Daemon
    ACTIONS = %w(status start stop restart).freeze

    class << self
      def run(rails_root)
        dir = File.expand_path('tmp/pids', rails_root)
        FileUtils.mkdir_p(dir)
        Daemons.run_proc 'tasks_scheduler', dir_mode: :normal, dir: dir do
          require File.join(rails_root, 'config', 'environment')
          ::TasksScheduler::Checker.instance.run
        end
      end

      def execute(action)
        raise "Action not allowed: #{action} (Allowed: #{ACTIONS})" unless ACTIONS.include?(action)
        command = ['bundle', 'exec', 'tasks_scheduler', action]
        Dir.chdir(Rails.root) do
          Open3.popen3(*command) do |_stdin, stdout, stderr, wait_thr|
            { action: action, command: command.join(' '), status: wait_thr.value.to_i,
              stdout: stdout.read, stderr: stderr.read }
          end
        end
      end
    end
  end
end
