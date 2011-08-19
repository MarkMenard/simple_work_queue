# require 'rubygems'
# require 'rake'
# require 'rake/clean'
require 'lib/simple_work_queue'
require 'bundler/gem_tasks'

# Load all rakefile extensions
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].each { |ext| load ext }

# Set default task
task :default => ["test:unit"]