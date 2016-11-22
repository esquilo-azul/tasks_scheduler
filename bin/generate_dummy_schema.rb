#!/usr/bin/env ruby
Dir.chdir(File.expand_path('../../test/dummy', __FILE__)) do
  File.unlink('db/test.sqlite3')
  system('bundle', 'exec', 'rake', 'db:migrate', 'RAILS_ENV=test')
end
