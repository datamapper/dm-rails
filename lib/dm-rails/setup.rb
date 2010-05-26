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
      initialize_foreign_keys
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
      if Object.const_defined?('DataObjects')
        DataObjects::Connection.send(:include, LogListener)
        # FIXME Setting DataMapper::Logger.new($stdout, :off) alone won't work because the #log
        # method is currently only available in DO and needs an explicit DO Logger instantiated.
        # We turn the logger :off because ActiveSupport::Notifications handles displaying log messages
        do_adapter = DataObjects.const_get(ActiveSupport::Inflector.camelize(adapter_name))
        do_adapter.logger = DataObjects::Logger.new($stdout, :off)
      end
    end

    def self.initialize_foreign_keys
      ::DataMapper::Model.descendants.each do |model|
        model.relationships.each_value { |r| r.child_key }
      end
    end

    def self.preload_models(app)
      app.config.paths.app.models.each do |path|
        Dir.glob("#{path}/**/*.rb").sort.each { |file| require_dependency file }
      end
      initialize_foreign_keys
    end

  end
end
