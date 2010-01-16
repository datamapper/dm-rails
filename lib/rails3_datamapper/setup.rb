require 'active_support/hash_with_indifferent_access'

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
        unless @config = normalize_config(config)
          raise ArgumentError, "Missing environment '#{env}' in database.yml file"
        end
      end

      def setup
        ::DataMapper.setup(:default, @config.except('repositories'))
        (@config['repositories'] || []).each do |repository_name, repository_config|
          ::DataMapper.setup(repository_name, repository_config)
        end       
      end

      private

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
