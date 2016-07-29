# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dm-rails/version'

Gem::Specification.new do |spec|
  spec.name             = "dm-rails"
  spec.version          = DataMapper::Rails::VERSION
  spec.authors          = [ 'Martin Gamsjaeger (snusnu)', 'Dan Kubb' ]
  spec.email            = [ 'gamsnjaga@gmail.com' ]
  spec.summary          = "Integrate DataMapper with Rails 3..5"
  spec.description      = spec.summary
  spec.homepage         = "http://datamapper.org"

  spec.files            = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files       = `git ls-files -- {spec}/*`.split("\n")
  spec.extra_rdoc_files = %w[LICENSE README.rdoc]

  spec.require_paths = [ "lib" ]

  spec.add_runtime_dependency('dm-active_model', '~> 1.2', '>= 1.2.0')
  spec.add_runtime_dependency('actionpack',      '>= 3.0', '< 6.0')
  spec.add_runtime_dependency('railties',        '>= 3.0', '< 6.0')

  spec.add_development_dependency('rake', '~> 0.9.2')
  spec.add_development_dependency('rspec')
end
