require 'active_support/core_ext/hash/except'

require 'dm-rails/configuration'
require 'dm-rails/railties/log_listener'
require 'dm-rails/railties/benchmarking_mixin'

module Rails
  module DataMapper

    def self.setup(environment)
      puts "[datamapper] Setting up the #{environment.inspect} environment:"
      configuration.repositories[environment].each do |name, config|
        setup_with_instrumentation(name.to_sym, config)
      end
      finalize
    end

    def self.setup_with_instrumentation(name, options)
      puts "[datamapper] Setting up #{name.inspect} repository: '#{options['database']}' on #{options['adapter']}"
      adapter = ::DataMapper.setup(name, options)
      adapter.extend ::DataMapper::Adapters::Benchmarking
      setup_log_listener(options['adapter'])
    end

    def self.setup_logger(logger)
      ::DataMapper.logger = logger
    end

    def self.setup_log_listener(adapter_name)
      driver_name = ActiveSupport::Inflector.camelize(adapter_name)
      if Object.const_defined?('DataObjects') && DataObjects.const_defined?(driver_name)
        DataObjects::Connection.send(:include, LogListener)
        # FIXME Setting DataMapper::Logger.new($stdout, :off) alone won't work because the #log
        # method is currently only available in DO and needs an explicit DO Logger instantiated.
        # We turn the logger :off because ActiveSupport::Notifications handles displaying log messages
        do_driver = DataObjects.const_get(driver_name)
        do_driver.logger = DataObjects::Logger.new($stdout, :off)
      end
    end

    def self.finalize
      ::DataMapper.finalize
    end

    def self.preload_models(app)
      app.config.paths.app.models.each do |path|
        Dir.glob("#{path}/**/*.rb").sort.each { |file| require_dependency file }
      end
      finalize
    end

  end
end
