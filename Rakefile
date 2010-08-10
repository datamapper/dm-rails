require 'rubygems'
require 'rake'

begin
  gem 'jeweler', '~> 1.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name        = 'dm-rails'
    gem.summary     = 'Use DataMapper with Rails 3'
    gem.description = 'Integrate DataMapper with Rails 3'
    gem.email       = 'gamsnjaga@gmail.com'
    gem.homepage    = 'http://github.com/datamapper/%s' % gem.name
    gem.authors     = [ 'Martin Gamsjaeger (snusnu)', 'Dan Kubb' ]

    gem.rubyforge_project = 'datamapper'

    gem.add_dependency 'dm-core',         '~> 1.0.0'
    gem.add_dependency 'dm-active_model', '~> 1.0.0'
    gem.add_dependency 'activesupport',   '~> 3.0.0.rc'
    gem.add_dependency 'actionpack',      '~> 3.0.0.rc'
    gem.add_dependency 'railties',        '~> 3.0.0.rc'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end

task(:spec) {} # stub out the spec task for as long as we don't have any specs
