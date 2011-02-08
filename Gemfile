require 'pathname'

source 'http://rubygems.org'

SOURCE       = ENV['SOURCE']   ? ENV['SOURCE'].to_sym              : :git
REPO_POSTFIX = SOURCE == :path ? ''                                : '.git'
DATAMAPPER   = SOURCE == :path ? Pathname(__FILE__).dirname.parent : 'http://github.com/datamapper'
DM_VERSION   = '~> 1.0.0'

group :runtime do

  git 'git://github.com/rails/rails.git', :branch => '3-0-stable' do

    gem 'activesupport', :require => 'active_support'
    gem 'actionpack',    :require => 'action_pack'
    gem 'railties',      :require => 'rails'

  end

  gem 'dm-core',         DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-core#{REPO_POSTFIX}"
  gem 'dm-active_model', DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-active_model#{REPO_POSTFIX}", :branch => 'rails-3.0.x'

end

group :development do

  gem 'rake',            '~> 0.8.7'
  gem 'jeweler',         '~> 1.4.0'
  gem 'rspec',           '~> 1.3.1'
end

group :quality do # These gems contain rake tasks that check the quality of the source code

  gem 'rcov',            '~> 0.9.7'
  gem 'yard',            '~> 0.5'
  gem 'yardstick',       '~> 0.1'

end

group :datamapper do
  adapters = ENV['ADAPTER'] || ENV['ADAPTERS']
  adapters = adapters.to_s.tr(',', ' ').split.uniq - %w[ in_memory ]

  DO_VERSION     = '~> 0.10.2'
  DM_DO_ADAPTERS = %w[ sqlite postgres mysql oracle sqlserver ]

  if (do_adapters = DM_DO_ADAPTERS & adapters).any?
    options = {}
    options[:git] = "#{DATAMAPPER}/do#{REPO_POSTFIX}" if ENV['DO_GIT'] == 'true'

    gem 'data_objects',  DO_VERSION, options.dup

    do_adapters.each do |adapter|
      adapter = 'sqlite3' if adapter == 'sqlite'
      gem "do_#{adapter}", DO_VERSION, options.dup
    end

    gem 'dm-do-adapter', DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-do-adapter#{REPO_POSTFIX}"
    gem 'dm-migrations', DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-migrations#{REPO_POSTFIX}"
  end

  adapters.each do |adapter|
    gem "dm-#{adapter}-adapter", DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-#{adapter}-adapter#{REPO_POSTFIX}"
  end
end
