require 'rubygems'
require 'rake'

begin
  gem 'jeweler', '~> 1.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|

    gem.name        = 'rails3_datamapper'
    gem.summary     = 'Use DataMapper with Rails 3'
    gem.description = 'Integrate DataMapper with Rails 3'
    gem.email       = 'dan.kubb@gmail.com'
    gem.homepage    = 'http://github.com/dkubb/rails3_datamapper'
    gem.authors     = [ 'Dan Kubb' ]

    gem.add_dependency 'dm-core',         '~> 0.10.2'
    gem.add_dependency 'dm-active_model', '~> 0.2'
    gem.add_dependency 'rails',           '~> 3.0'

    gem.add_development_dependency 'rspec', '~> 1.2.9'
    gem.add_development_dependency 'yard',  '~> 0.5'

  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }

rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
