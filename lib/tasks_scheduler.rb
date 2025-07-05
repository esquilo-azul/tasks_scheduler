# frozen_string_literal: true

require 'eac_ruby_utils'
EacRubyUtils::RootModuleSetup.perform __FILE__

module TasksScheduler
end

require 'avm/eac_generic_base0'
require 'avm/eac_ruby_base1'
require 'daemons'
require 'parse-cron'
require 'rails'

require 'tasks_scheduler/engine'
