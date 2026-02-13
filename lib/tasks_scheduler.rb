# frozen_string_literal: true

require 'eac_ruby_utils'
EacRubyUtils::RootModuleSetup.perform __FILE__

module TasksScheduler
end

require 'avm/eac_ruby_base1'
require 'eac_active_scaffold'
require 'eac_rails_utils'

require 'tasks_scheduler/engine'
