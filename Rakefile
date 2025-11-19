require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'vendor/storm_meta/lib'
  t.libs << 'lib'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

task default: :test