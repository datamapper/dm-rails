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

require 'dm-rails/setup'
require "dm-rails/railties/log_subscriber"
require "dm-rails/railties/i18n_support"


module Rails
  module DataMapper

    class Railtie < Rails::Railtie

      log_subscriber :data_mapper, ::DataMapper::Railties::LogSubscriber.new

      config.generators.orm :data_mapper, :migration => true


      # Support overwriting crucial steps in subclasses

      def configure_data_mapper(app)
        app.config.data_mapper = Rails::DataMapper::Configuration.for(
          Rails.root, app.config.database_configuration
        )
      end

      def setup_i18n_support(app)
        ::DataMapper::Model.append_inclusions(Rails::DataMapper::I18nSupport)
      end

      def setup_controller_runtime(app)
        require "dm-rails/railties/controller_runtime"
        ActionController::Base.send :include, Rails::DataMapper::Railties::ControllerRuntime
      end

      def setup_logger(app, logger)
        Rails::DataMapper.setup_logger(logger)
      end


      initializer 'data_mapper.configuration' do |app|
        configure_data_mapper(app)
      end

      initializer 'data_mapper.logger' do |app|
        setup_logger(app, Rails.logger)
      end

      initializer 'data_mapper.i18n_support' do |app|
        setup_i18n_support(app)
      end

      # Expose database runtime to controller for logging.
      initializer "data_mapper.log_runtime" do |app|
        setup_controller_runtime(app)
      end

      # Preload all models once in production mode,
      # and before every request in development mode
      initializer "datamapper.add_to_prepare" do |app|
        config.to_prepare { Rails::DataMapper.preload_models(app) }
      end

      # Run setup code once in after_initialize to make sure all initializers
      # are in effect once we setup the connection. Also, this will make sure
      # that the connection gets set up after all models have been loaded,
      # because #after_initialize is guaranteed to run after #to_prepare.
      # Both production and development environment will execute the setup
      # code only once.
      config.after_initialize do |app|
        Rails::DataMapper.setup(Rails.env)
      end

      rake_tasks do
        load 'dm-rails/railties/database.rake'
      end

    end

  end
end
