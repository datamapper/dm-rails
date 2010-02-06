require 'dm-core'
require 'dm-active_model'

require 'rails'
require 'active_model/railtie'

# Comment taken from active_record/railtie.rb
#
# For now, action_controller must always be present with
# rails, so let's make sure that it gets required before
# here. This is needed for correctly setting up the middleware.
# In the future, this might become an optional require.
require 'action_controller/railtie'

require 'rails3_datamapper/setup'
require "rails3_datamapper/railties/subscriber"


module Rails
  module DataMapper

    class Railtie < Rails::Railtie

      railtie_name :data_mapper

      subscriber ::DataMapper::Railties::Subscriber.new


      DEFAULT_PLUGINS = %w(dm-validations dm-timestamps dm-observer dm-migrations)


      rake_tasks do
        load 'rails3_datamapper/railties/database.rake'
      end


      initializer 'data_mapper.generators' do |app|
        app.config.generators.orm = :data_mapper, :migration => true
      end

      initializer 'data_mapper.config_defaults' do |app|
        app.config.data_mapper.plugins           ||= DEFAULT_PLUGINS
        app.config.data_mapper.use_identity_map  ||= true
        app.config.data_mapper.adapter_cascade   ||= Rails::DataMapper::Adapters::Cascade
      end

      initializer 'data_mapper.configurations' do |app|
        Rails::DataMapper.configurations = app.config.database_configuration
      end

      initializer 'data_mapper.logger' do
        Rails::DataMapper.setup_logger(Rails.logger)
      end

      initializer 'data_mapper.adapter_cascade' do |app|
        app.config.data_mapper.adapter_cascade.configure do |cascade|
          cascade.use Rails::DataMapper::Adapters::BenchmarkingAdapter
        end
      end

      initializer 'data_mapper.setup_identity_map' do |app|
        if app.config.data_mapper.use_identity_map
          require 'rails3_datamapper/middleware/identity_map'
          app.config.middleware.use Middleware::IdentityMap
        end
      end

      initializer 'data_mapper.routing_support' do
        Rails::DataMapper.setup_routing_support
      end

      # Expose database runtime to controller for logging.
      initializer "data_mapper.log_runtime" do |app|
        require "rails3_datamapper/railties/controller_runtime"
        ActionController::Base.send :include, Railties::ControllerRuntime
      end


      # Run setup code after_initialize to make sure all config/initializers
      # are in effect once we setup the connection. This is especially necessary
      # for the cascaded adapter wrappers that need to be declared before setup.

      config.after_initialize do |app|

        Rails::DataMapper.setup(app.config.database_configuration[Rails.env])

        app.config.data_mapper.plugins.each do |plugin|
          require plugin.to_s
        end

        app.config.paths.lib.each do |path|
          Dir.glob("#{path}/**/*.rb").sort.each { |file| require file }
        end

        app.config.paths.app.models.each do |path|
          Dir.glob("#{path}/**/*.rb").sort.each { |file| require file }
        end

        ::DataMapper::Model.descendants.each do |model|
          model.relationships.each_value { |r| r.child_key }
        end

      end

    end

  end
end
