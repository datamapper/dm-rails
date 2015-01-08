# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dm-rails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors     = [ 'Martin Gamsjaeger (snusnu)', 'Dan Kubb' ]
  gem.email       = [ 'gamsnjaga@gmail.com' ]
  gem.summary     = "Integrate DataMapper with Rails 3"
  gem.description = gem.summary
  gem.homepage    = "http://datamapper.org"

  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE README.rdoc]

  gem.name          = "dm-rails"
  gem.require_paths = [ "lib" ]
  gem.version       = DataMapper::Rails::VERSION

  gem.add_runtime_dependency('dm-active_model', '~> 1.2', '>= 1.2.0')
  gem.add_runtime_dependency('actionpack',      '>= 3.0', '< 5.0')
  gem.add_runtime_dependency('railties',        '>= 3.0', '< 5.0')

  gem.add_development_dependency('rake',      '~> 0.9.2')
  gem.add_development_dependency('rspec',     '~> 1.3.2')
end
