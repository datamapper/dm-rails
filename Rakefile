require 'rubygems'
require 'rake'

FileList['tasks/**/*.rake'].each { |task| import task }

require "spec/rake/spectask"
Spec::Rake::SpecTask.new

task :default => :spec
