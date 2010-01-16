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


      rake_tasks do
        load 'rails3_datamapper/railties/database.rake'
      end

      initializer 'data_mapper.generators' do |app|
        app.config.generators.orm = :data_mapper
      end

      initializer 'data_mapper.config_defaults' do |app|
        app.config.data_mapper.use_identity_map    ||= true
        app.config.data_mapper.plugins ||= %w(dm-validations dm-timestamps)
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

      initializer 'data_mapper.setup_identity_map' do |app|
        if app.config.data_mapper.use_identity_map
          require 'rails3_datamapper/middleware/identity_map'
          app.config.middleware.use Middleware::IdentityMap
        end
      end

      initializer 'data_mapper.plugins' do |app|
        app.config.data_mapper.plugins.each do |plugin|
          require plugin.to_s
        end
      end

      initializer 'data_mapper.preload_lib' do |app|
        app.config.paths.lib.each do |path|
          Dir.glob("#{path}/**/*.rb").each { |file| require file }
        end
      end

      initializer 'data_mapper.preload_models' do |app|
        app.config.paths.app.models.each do |path|
          Dir.glob("#{path}/**/*.rb").each { |file| require file }
        end
      end

      # This depends on all models being loaded
      initializer 'data_mapper.property_initializer' do
        ::DataMapper::Model.descendants.each do |model|
          model.relationships.each_value { |r| r.child_key }
        end
      end

      initializer 'data_mapper.routing_support' do
        Rails::DataMapper.setup_routing_support
      end

    end

  end
end
