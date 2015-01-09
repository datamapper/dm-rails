require 'active_support/core_ext/hash/except'

require 'dm-rails/configuration'
require 'dm-rails/railties/log_listener'

module Rails
  module DataMapper
    def self.setup(environment)
      ::DataMapper.logger.info "[datamapper] Setting up the #{environment.inspect} environment:"
      env = configuration.repositories.fetch(environment) do
        database_url = ENV['DATABASE_URL']
        if database_url.present?
          { 'default' => { 'url' => database_url } }
        else
          fail KeyError, "The environment #{environment} is unknown"
        end
      end
      env.symbolize_keys.each { |pair| setup_with_instrumentation(*pair) }
      finalize
    end

    def self.setup_with_instrumentation(name, options)
      # The url option is the convention used by rails, while uri is legacy dm-rails
      url = options.fetch('url', options['uri'])
      args, database, adapter_name = if url
        database_uri = ::Addressable::URI.parse(url)
        [database_uri, database_uri.path[1..-1], database_uri.scheme]
      else
        [options, *options.values_at('database', 'adapter')]
      end

      ::DataMapper.logger.info "[datamapper] Setting up #{name.inspect} repository: '#{database}' on #{adapter_name}"
      adapter = ::DataMapper.setup(name, args)

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
