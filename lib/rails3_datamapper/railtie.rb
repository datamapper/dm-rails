require 'dm-core'
require 'dm-active_model'

require 'rails3_datamapper/config'

# Comment taken from active_record/railtie.rb
#
# For now, action_controller must always be present with
# rails, so let's make sure that it gets required before
# here. This is needed for correctly setting up the middleware.
# In the future, this might become an optional require.
require 'action_controller/railtie'
require 'rails'


module Rails
  module DataMapper

    class Railtie < Rails::Railtie

      plugin_name :data_mapper

      rake_tasks do
        load 'rails3_datamapper/railties/database.rake'
      end

      initializer 'data_mapper.setup_repositories' do |app|
        Rails::DataMapper::Config.setup_repositories
      end

      initializer 'data_mapper.logger' do
        ::DataMapper.logger = Rails.logger
      end

    end

  end
end
