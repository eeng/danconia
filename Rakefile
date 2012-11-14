require "bundler/gem_tasks"
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'lib/acts_as_money'
  t.test_files = FileList['test/acts_as_money/*_test.rb']
  t.verbose = true
end
task :default => :test