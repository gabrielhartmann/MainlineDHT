require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib/bencode'
  t.test_files = FileList['test/node/*_test.rb']
  t.verbose = true
end

task :default => :test

