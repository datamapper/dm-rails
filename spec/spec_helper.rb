begin
  # Just in case the bundle was locked
  # This shouldn't happen in a dev environment but lets be safe
  require File.expand_path('../../.bundle/environment', __FILE__)
rescue LoadError
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end
Bundler.require(:default, :test)

$LOAD_PATH.unshift(File.expand_path('../', __FILE__))
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'dm-rails'

require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
end
