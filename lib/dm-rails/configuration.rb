require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/class/attribute_accessors'

module Rails
  module DataMapper

    mattr_accessor :configuration

    class Configuration

      attr_accessor :raw
      attr_accessor :root

      def self.create
        Rails::DataMapper.configuration ||= new
      end

      def environments
        raw.keys
      end

      def repositories
        @repositories ||= raw.reject { |k,v| k =~ /defaults/ }.inject({}) do |repositories, pair|
          environment, config = pair.first, pair.last
          repositories[environment] = begin
            c = config['repositories'] || {}
            c['default'] = config.except('repositories') if config.except('repositories')
            normalize_repository_config(c)
          end
          repositories
        end
      end

      def resource_naming_convention
        @resource_naming_convention ||= {}
      end

    private

      def normalize_repository_config(hash)
        config = {}
        hash.each do |key, value|

          config[key] = if value.kind_of?(Hash)
            normalize_repository_config(value)
          elsif key == 'port'
            value.to_i
          elsif key == 'adapter' && value == 'postgresql'
            'postgres'
          elsif (key == 'database' || key == 'path') && hash['adapter'] =~ /sqlite/
            value == ':memory:' ? value : File.expand_path(hash[key], root)
          else
            value
          end

          # FIXME Rely on a new dm-sqlite-adapter to do the right thing
          # For now, we need to make sure that both 'path' and 'database'
          # point to the same thing, since dm-sqlite-adapter always passes
          # both to the underlying do_sqlite3 adapter and there's no
          # guarantee which one will be used

          config['path']     = config[key] if key == 'database'
          config['database'] = config[key] if key == 'path'

        end
        config
      end

    end

  end
end
