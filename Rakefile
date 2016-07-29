require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

# require "spec/rake/spectask"
# Spec::Rake::SpecTask.new

FileList['tasks/**/*.rake'].each { |task| import task }

task :default => :spec
