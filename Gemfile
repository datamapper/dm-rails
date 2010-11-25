require 'pathname'

source 'http://rubygems.org'

SOURCE       = ENV['SOURCE']   ? ENV['SOURCE'].to_sym              : :git
REPO_POSTFIX = SOURCE == :path ? ''                                : '.git'
DATAMAPPER   = SOURCE == :path ? Pathname(__FILE__).dirname.parent : 'http://github.com/datamapper'
DM_VERSION   = '~> 1.0.0'

group :runtime do

  git 'git://github.com/rails/rails.git' do

    gem 'activesupport', :require => 'active_support'
    gem 'actionpack',    :require => 'action_pack'
    gem 'railties',      :require => 'rails'

  end

  gem 'dm-core',         DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-core#{REPO_POSTFIX}"
  gem 'dm-active_model', DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-active_model#{REPO_POSTFIX}"

end

group :development do

  gem 'rake',            '~> 0.8.7'
  gem 'jeweler',         '~> 1.4.0'

end

group :quality do # These gems contain rake tasks that check the quality of the source code

  gem 'rcov',            '~> 0.9.7'
  gem 'yard',            '~> 0.5'
  gem 'yardstick',       '~> 0.1'

end
