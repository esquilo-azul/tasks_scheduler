# frozen_string_literal: true

require 'eac_active_scaffold/engine'
require 'eac_rails_utils/engine'
require 'eac_rails_utils/engine_helper'

module TasksScheduler
  class Engine < ::Rails::Engine
    include ::EacRailsUtils::EngineHelper
  end
end
