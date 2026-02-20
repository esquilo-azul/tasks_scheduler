# frozen_string_literal: true

require 'avm/eac_ruby_base1'
require 'eac_active_scaffold'
require 'eac_rails_utils'
require 'eac_ruby_utils'

module TasksScheduler
  class Engine < ::Rails::Engine
    include ::EacRailsUtils::EngineHelper
  end
end
