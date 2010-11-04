source 'http://rubygems.org'

DATAMAPPER = 'git://github.com/datamapper'
DM_VERSION = '~> 1.0.0'

group :runtime do

  git 'git://github.com/rails/rails.git', :branch => '3-0-stable' do

    gem 'activesupport', :require => 'active_support'
    gem 'actionpack',    :require => 'action_pack'
    gem 'railties',      :require => 'rails'

  end

  gem 'dm-core',         DM_VERSION, :git => "#{DATAMAPPER}/dm-core.git"
  gem 'dm-active_model', DM_VERSION, :git => "#{DATAMAPPER}/dm-active_model.git"

end

group :development do

  gem 'rake',            '~> 0.8.7'
  gem 'jeweler',         '~> 1.4'

end

group :quality do # These gems contain rake tasks that check the quality of the source code

  gem 'rcov',            '~> 0.9.7'
  gem 'yard',            '~> 0.5'
  gem 'yardstick',       '~> 0.1'

end
