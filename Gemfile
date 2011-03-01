require 'pathname'

source 'http://rubygems.org'

SOURCE       = ENV.fetch('SOURCE', :git).to_sym
REPO_POSTFIX = SOURCE == :path ? ''                                : '.git'
DATAMAPPER   = SOURCE == :path ? Pathname(__FILE__).dirname.parent : 'http://github.com/datamapper'
DM_VERSION   = '~> 1.0.2'

group :runtime do

  gem 'actionpack',      '~> 3.0.4', :require => 'action_pack'
  gem 'activesupport',   '~> 3.0.4', :require => 'active_support'
  gem 'dm-core',         DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-core#{REPO_POSTFIX}"
  gem 'dm-active_model', DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-active_model#{REPO_POSTFIX}"
  gem 'i18n',            '~> 0.5.0'
  gem 'railties',        '~> 3.0.4', :require => 'rails'

end

group :development do

  gem 'jeweler', '~> 1.5.2'
  gem 'rake',    '~> 0.8.7'
  gem 'rspec',   '~> 1.3.1'

end

group :quality do

  gem 'rcov',      '~> 0.9.7', :platforms => :mri_18
  gem 'yard',      '~> 0.5'
  gem 'yardstick', '~> 0.1'

end

group :datamapper do
  adapters = ENV['ADAPTER'] || ENV['ADAPTERS']
  adapters = adapters.to_s.tr(',', ' ').split.uniq - %w[ in_memory ]

  DO_VERSION     = '~> 0.10.2'
  DM_DO_ADAPTERS = %w[ sqlite postgres mysql oracle sqlserver ]

  if (do_adapters = DM_DO_ADAPTERS & adapters).any?
    options = {}
    options[:git] = "#{DATAMAPPER}/do#{REPO_POSTFIX}" if ENV['DO_GIT'] == 'true'

    gem 'data_objects', DO_VERSION, options.dup

    do_adapters.each do |adapter|
      adapter = 'sqlite3' if adapter == 'sqlite'
      gem "do_#{adapter}", DO_VERSION, options.dup
    end

    gem 'dm-do-adapter', DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-do-adapter#{REPO_POSTFIX}"
  end

  gem 'dm-migrations', DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-migrations#{REPO_POSTFIX}"

  adapters.each do |adapter|
    gem "dm-#{adapter}-adapter", DM_VERSION, SOURCE => "#{DATAMAPPER}/dm-#{adapter}-adapter#{REPO_POSTFIX}"
  end
end
