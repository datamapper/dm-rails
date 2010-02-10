require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/class/attribute_accessors'

module Rails
  module DataMapper

    mattr_accessor :configuration

    class Configuration

      DEFAULT_PLUGINS = %w(dm-validations dm-timestamps dm-observer dm-migrations)

      def self.for(root, database_yml_hash)
        Rails::DataMapper.configuration ||= new(root, database_yml_hash)
      end

      attr_reader :root, :raw

      def environments
        config.keys
      end

      def repositories
        @repositories ||= @raw.reject { |k,v| k =~ /defaults/ }.inject({}) do |repositories, pair|
          environment, config = pair.first, pair.last
          repositories[environment] = begin
            c = config['repositories'] || {}
            c['default'] = config.except('repositories') if config.except('repositories')
            normalize_repository_config(c)
          end
          repositories
        end
      end


      def identity_map=(value)
        @identity_map = value
      end

      def identity_map
        @identity_map ||= true
      end


      def plugins=(*plugins)
        @plugins = (DEFAULT_PLUGINS + plugins).uniq!
      end

      def plugins
        @plugins ||= DEFAULT_PLUGINS
      end


      def adapter_cascade
        @adapter_cascade ||= Rails::DataMapper::Adapters::Cascade
      end


      private

      def initialize(root, database_yml_hash)
        @root, @raw = root, database_yml_hash
      end

      def normalize_repository_config(hash)
        config = {}
        hash.each do |key, value|
          config[key] = if value.kind_of?(Hash)
            normalize_repository_config(value)
          elsif key == 'port'
            value.to_i
          elsif key == 'adapter' && value == 'postgresql'
            'postgres'
          elsif key == 'database' && hash['adapter'] == 'sqlite3'
            File.expand_path(hash['database'], root)
          else
            value
          end
        end
        config
      end

    end

  end
end
