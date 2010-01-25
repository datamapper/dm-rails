require 'active_support/core_ext/hash/except'
require 'rails3_datamapper/adapters'

module Rails
  module DataMapper

    def self.configurations=(database_yml_hash)
      @configurations = database_yml_hash
    end

    def self.configurations
      @configurations
    end


    def self.setup(config)
      Initializer.new(config).setup
    end

    def self.setup_logger(logger)
      ::DataMapper.logger = logger
    end

    def self.setup_routing_support
      ::DataMapper::Model.append_inclusions(RoutingSupport)
    end


    class Initializer

      def initialize(config)
        @config = normalize_config(config)
        if @config.empty?
          raise ArgumentError, "Missing '#{Rails.env}' environment in config/database.yml"
        end
      end

      def setup
        setup_with_instrumentation(:default, @config.except('repositories'))
        (@config['repositories'] || []).each do |repository_name, repository_config|
          setup_with_instrumentation(repository_name, repository_config)
        end
      end

      private

      def setup_with_instrumentation(name, options)
        adapter = ::DataMapper.setup(name, options)
        Adapters::Cascade.push(Adapters::BenchmarkingAdapter)
        ::DataMapper::Repository.adapters[adapter.name] = Adapters::Cascade.setup(adapter)
      end

      def normalize_config(hash)
        config = {}

        hash.each do |key, value|
          config[key] = if value.kind_of?(Hash)
            normalize_config(value)
          elsif key == 'port'
            value.to_i
          elsif key == 'adapter' && value == 'postgresql'
            'postgres'
          else
            value
          end
        end

        config
      end

    end

    module RoutingSupport

      # I'm not sure wether this is active_model related or not
      # but I can't remember any mention of #to_param in that
      # context. If it is, this is probably better placed in
      # dm-active_model, but for now it's fine to put it here.
      # If this is not present, action_view helpers seem to be
      # unable to identify a resource in routes
      def to_param
        id
      end

    end

  end
end
