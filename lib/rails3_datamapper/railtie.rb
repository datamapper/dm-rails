require 'dm-core'
require 'dm-active_model'

require 'rails3_datamapper/setup'

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

      config.generators.orm = :datamapper


      rake_tasks do
        load 'rails3_datamapper/railties/database.rake'
      end


      initializer 'data_mapper.configurations' do |app|
        Rails::DataMapper.configurations = app.config.database_configuration
      end

      initializer 'data_mapper.logger' do
        Rails::DataMapper.setup_logger(Rails.logger)
      end

      initializer 'data_mapper.setup_repositories' do |app|
        Rails::DataMapper.setup(app.config.database_configuration[Rails.env])
      end

      initializer 'data_mapper.routing_support' do
        Rails::DataMapper.setup_routing_support
      end

    end

  end
end
