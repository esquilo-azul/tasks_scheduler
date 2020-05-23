# frozen_string_literal: true

require 'eac_ruby_gems_utils/gem'
require 'singleton'

module TasksScheduler
  class AppGem < ::SimpleDelegator
    include ::Singleton

    def initialize
      super(::EacRubyGemsUtils::Gem.new(::Rails.root))
    end

    def bundle(*args)
      super(*args).chdir_root.envvar('RAILS_ENV', ::Rails.env)
    end
  end
end
