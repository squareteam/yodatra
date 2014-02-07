require 'rubygems'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |task|
  task.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  task.pattern    = 'spec/**/*_spec.rb'
end

require 'coveralls/rake/task'
Coveralls::RakeTask.new
task :test_with_coveralls => [:spec, :features, 'coveralls:push']

task :default => :spec