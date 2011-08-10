require 'active_support/core_ext/hash/except'

require 'dm-rails/configuration'
require 'dm-rails/railties/log_listener'

module Rails
  module DataMapper

    def self.setup(environment)
      ::DataMapper.logger.info "[datamapper] Setting up the #{environment.inspect} environment:"
      configuration.repositories[environment].each do |name, config|
        setup_with_instrumentation(name.to_sym, config)
      end
      finalize
    end

    def self.setup_with_instrumentation(name, options)
      adapter = if options['uri']
                  database_uri = URI.parse(options['uri'])
                  ::DataMapper.logger.info "[datamapper] Setting up #{name} repository: '#{database_uri.path}' on #{database_uri.scheme}"
                  ::DataMapper.setup(name, options['uri'])
                else
                  ::DataMapper.logger.info "[datamapper] Setting up #{name.inspect} repository: '#{options['database']}' on #{options['adapter']}"
                 ::DataMapper.setup(name, options)
                end

      if convention = configuration.resource_naming_convention[name]
        adapter.resource_naming_convention = convention
      end
      if convention = configuration.field_naming_convention[name]
        adapter.field_naming_convention = convention
      end
      setup_log_listener(adapter.options['adapter'])
    end

    def self.setup_logger(logger)
      ::DataMapper.logger = logger
    end

    def self.setup_log_listener(adapter_name)
      adapter_name = 'sqlite3' if adapter_name == 'sqlite'
      driver_name  = ActiveSupport::Inflector.camelize(adapter_name)

      setup_do_driver(driver_name) do |driver|
        DataObjects::Connection.send(:include, LogListener)
        # FIXME Setting DataMapper::Logger.new($stdout, :off) alone won't work because the #log
        # method is currently only available in DO and needs an explicit DO Logger instantiated.
        # We turn the logger :off because ActiveSupport::Notifications handles displaying log messages
        driver.logger = DataObjects::Logger.new($stdout, :off)
      end
    end

    def self.finalize
      ::DataMapper.finalize
    end

    def self.preload_models(app)
      app.config.paths['app/models'].each do |path|
        Dir.glob("#{path}/**/*.rb").sort.each { |file| require_dependency file[path.length..-1] }
      end
      finalize
    end

    class << self
      private

      if RUBY_VERSION < '1.9'
        def setup_do_driver(driver_name)
          if Object.const_defined?('DataObjects') && DataObjects.const_defined?(driver_name)
            yield DataObjects.const_get(driver_name)
          end
        end
      else
        def setup_do_driver(driver_name)
          if Object.const_defined?('DataObjects', false) && DataObjects.const_defined?(driver_name, false)
            yield DataObjects.const_get(driver_name, false)
          end
        end
      end
    end

  end
end
