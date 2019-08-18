require 'fileutils'

module TasksScheduler
  class Checker
    class Log
      class << self
        def logs_directory
          @logs_directory ||= ::Rails.root.join('log', 'tasks_scheduler', 'checker')
        end
      end

      attr_reader :key

      def initialize(key)
        @key = key
        ::FileUtils.mkdir_p(dirname)
      end

      def dirname
        ::File.dirname(path)
      end

      def path
        self.class.logs_directory.join("#{key}.log")
      end
    end
  end
end
