$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'tasks_scheduler/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'tasks_scheduler'
  s.version     = TasksScheduler::VERSION
  s.authors     = ['Eduardo H. Bogoni']
  s.email       = ['eduardobogoni@gmail.com']
  s.summary     = 'Scheduler for Rake tasks.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib,exe}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']
  s.bindir = 'exe'
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }

  s.add_dependency 'active_scaffold'
  s.add_dependency 'daemons'
  s.add_dependency 'js-routes'
  s.add_dependency 'parse-cron'
  s.add_dependency 'rails', '~> 4.2.1'

  s.add_development_dependency 'sqlite3'
end
