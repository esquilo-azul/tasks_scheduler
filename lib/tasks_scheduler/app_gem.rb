# frozen_string_literal: true

require 'avm/eac_ruby_base1/sources/base'
require 'singleton'

module TasksScheduler
  class AppGem < ::SimpleDelegator
    include ::Singleton

    def initialize
      super(::Avm::EacRubyBase1::Sources::Base.new(::Rails.root))
    end

    def bundle(*args)
      super.chdir_root.envvar('RAILS_ENV', ::Rails.env)
    end
  end
end
