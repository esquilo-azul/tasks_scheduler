# frozen_string_literal: true

require 'eac_ruby_utils'
require 'avm/eac_generic_base0'
require 'avm/eac_ruby_base1'
require 'daemons'
require 'parse-cron'
require 'rails'

require 'eac_active_scaffold/engine'
require 'eac_rails_utils/engine'
require 'eac_rails_utils/engine_helper'

module TasksScheduler
  class Engine < ::Rails::Engine
    include ::EacRailsUtils::EngineHelper
  end
end
