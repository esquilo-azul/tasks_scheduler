# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'tasks_scheduler/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'tasks_scheduler'
  s.version     = TasksScheduler::VERSION
  s.authors     = ['Eduardo H. Bogoni']
  s.email       = ['eduardobogoni@gmail.com']
  s.summary     = 'Scheduler for Rake tasks.'
  s.homepage    = 'https://github.com/esquilo-azul/tasks_scheduler'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib,exe}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.bindir = 'exe'
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.required_ruby_version = '>= 2.7.0'

  s.add_dependency 'avm-eac_ruby_base1', '~> 0.35', '>= 0.35.1'
  s.add_dependency 'daemons', '~> 1.4', '>= 1.4.1'
  s.add_dependency 'eac_active_scaffold', '~> 0.6', '>= 0.6.1'
  s.add_dependency 'eac_rails_utils', '~> 0.25'
  s.add_dependency 'eac_ruby_utils', '~> 0.123'
  s.add_dependency 'parse-cron', '~> 0.1', '>= 0.1.4'

  s.add_development_dependency 'eac_rails_gem_support', '~> 0.10', '>= 0.10.1'
end
