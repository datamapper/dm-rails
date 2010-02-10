# Setup your complete development environment by running the following:
#
#   gem install bundler #if you haven't done so before
#   bundle install
#   rake spec
#

source 'http://gemcutter.org'

gem 'rake'

gem 'yard',           '~> 0.5'

gem 'data_objects',   '~> 0.10.1'
gem 'do_sqlite3',     '~> 0.10.1'

git 'git://github.com/carlhuda/bundler.git'

gem 'bundler'

git 'git://github.com/rails/rails.git'

gem 'activesupport',  '~> 3.0.0.beta1', :require => 'active_support'
gem 'actionpack',     '~> 3.0.0.beta1', :require => 'action_pack'
gem 'railties',       '~> 3.0.0.beta1', :require => 'rails'

git 'git://github.com/snusnu/dm-core.git', 'branch' => 'active_support'
git 'git://github.com/snusnu/dm-more.git', 'branch' => 'active_support'

gem 'dm-core'

gem 'dm-core',        '~> 0.10.2'
gem 'dm-types',       '~> 0.10.2'
gem 'dm-validations', '~> 0.10.2'
gem 'dm-constraints', '~> 0.10.2'
gem 'dm-aggregates',  '~> 0.10.2'
gem 'dm-timestamps',  '~> 0.10.2'
gem 'dm-migrations',  '~> 0.10.2'
gem 'dm-observer',    '~> 0.10.2'

git 'git://github.com/snusnu/dm-active_model.git'

gem 'dm-active_model'


group(:test) do
  gem 'rspec',   '~> 1.3', :require => 'spec'
end

group(:development) do
  gem 'jeweler', '~> 1.4'
end
