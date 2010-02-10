require 'active_support/core_ext/hash/except'

require 'rails3_datamapper/configuration'
require 'rails3_datamapper/adapters'

module Rails
  module DataMapper

    def self.setup(environment)
      puts "[datamapper] Setting up the #{environment.inspect} environment:"
      configuration.repositories[environment].each do |name, config|
        setup_with_instrumentation(name.to_sym, config)
      end
      initialize_foreign_keys
    end

    def self.setup_logger(logger)
      ::DataMapper.logger = logger
    end

    def self.setup_with_instrumentation(name, options)
      puts "[datamapper] Setting up #{name.inspect} repository: '#{options['database']}' on #{options['adapter']}"
      adapter = ::DataMapper.setup(name, options)
      ::DataMapper::Repository.adapters[adapter.name] = adapter_cascade(adapter)
    end

    def self.initialize_foreign_keys
      ::DataMapper::Model.descendants.each do |model|
        model.relationships.each_value { |r| r.child_key }
      end
    end

    def self.adapter_cascade(adapter)
      Adapters::Cascade.instantiate(adapter)
    end

  end
end
