# frozen_string_literal: true

require 'eac_active_scaffold'
require 'eac_rails_utils/engine'

module TasksScheduler
  class Engine < ::Rails::Engine
    initializer :append_migrations do |app|
      config.paths['db/migrate'].expanded.each do |expanded_path|
        app.config.paths['db/migrate'] << expanded_path
      end
    end
  end
end
