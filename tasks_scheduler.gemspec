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
  s.test_files = Dir['test/**/*']
  s.bindir = 'exe'
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }

  s.add_dependency 'active_scaffold'
  s.add_dependency 'daemons'
  s.add_dependency 'eac_ruby_gems_utils', '~> 0.4', '>= 0.4.1'
  s.add_dependency 'js-routes'
  s.add_dependency 'parse-cron'
  s.add_dependency 'rails', '>= 4.2.11.3'

  s.add_development_dependency 'eac_ruby_gem_support', '~> 0.1', '>= 0.1.1'
  s.add_development_dependency 'sqlite3', '~> 1.3.13'
end
