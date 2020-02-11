#!/usr/bin/env ruby
# frozen_string_literal: true

Dir.chdir(File.expand_path('../test/dummy', __dir__)) do
  File.unlink('db/test.sqlite3')
  system('bundle', 'exec', 'rake', 'db:migrate', 'RAILS_ENV=test')
end
