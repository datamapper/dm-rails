# Setup your complete development environment by running the following:
#
#   gem install bundler #if you haven't done so before
#   bundle install
#   rake spec
#

source 'http://rubygems.org'

gem 'rake'

gem 'yard',             '~> 0.5'

gem 'data_objects',     '~> 0.10.1'
gem 'do_sqlite3',       '~> 0.10.1'
# gem 'do_mysql',       '~> 0.10.1'
# gem 'do_postgres',    '~> 0.10.1'

git 'git://github.com/rails/rails.git' do

  gem 'activesupport',  '~> 3.0.0.beta1', :require => 'active_support'
  gem 'actionpack',     '~> 3.0.0.beta1', :require => 'action_pack'
  gem 'railties',       '~> 3.0.0.beta1', :require => 'rails'

end

gem 'dm-core',          '~> 0.10.2', :git => 'git://github.com/datamapper/dm-core.git'

git 'git://github.com/datamapper/dm-more.git' do

  gem 'dm-types',       '~> 0.10.2'
  gem 'dm-validations', '~> 0.10.2'
  gem 'dm-constraints', '~> 0.10.2'
  gem 'dm-aggregates',  '~> 0.10.2'
  gem 'dm-timestamps',  '~> 0.10.2'
  gem 'dm-migrations',  '~> 0.10.2'
  gem 'dm-observer',    '~> 0.10.2'

end

gem 'dm-active_model',  '~> 0.4', :git => 'git://github.com/datamapper/dm-active_model.git'


group(:test) do
  gem 'rspec',          '~> 1.3', :require => 'spec'
end

group(:development) do
  gem 'jeweler',        '~> 1.4'
end
