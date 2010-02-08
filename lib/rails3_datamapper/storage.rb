module Rails
  module DataMapper

    def self.storage
      Storage
    end

    class Storage
      attr_reader :name, :config

      def self.create_all
        with_local_repositories { |config| create_environment(config) }
      end

      def self.drop_all
        with_local_repositories { |config| drop_environment(config) }
      end

      def self.create_environment(config)
        config.each { |repo_name, repo_config| new(repo_name, repo_config).create }
      end

      def self.drop_environment(config)
        config.each { |repo_name, repo_config| new(repo_name, repo_config).drop }
      end

      def self.new(name, config)
        klass = lookup_class(config['adapter'])
        if klass.equal?(self)
          super(name, config)
        else
          klass.new(name, config)
        end
      end

      class << self
      private

        def with_local_repositories
          Rails::DataMapper.configuration.repositories.each_value do |config|
            if config['host'].blank? || %w[ 127.0.0.1 localhost ].include?(config['host'])
              yield(config)
            else
              puts "This task only modifies local databases. #{config['database']} is on a remote host."
            end
          end
        end

        def lookup_class(adapter)
          klass_name = adapter.classify.to_sym

          unless const_defined?(klass_name)
            raise "Adapter #{adapter} not supported"
          end

          const_get(klass_name)
        end

      end

      def initialize(name, config)
        @name, @config = name.to_sym, config
      end

      def create
        _create
        puts "Created database '#{database}' for #{name}"
      end

      def drop
        _drop
        puts "Dropped database '#{database}' for #{name}"
      end

      def database
        @database ||= config['database'] || config['path']
      end

      def username
        @username ||= config['username']
      end

      def password
        @password ||= config['password']
      end

    private

      class Sqlite < Storage
        def _create
          ::DataMapper.setup(name, config)
        end

        def _drop
          path = Pathname(database)
          path = Rails.root.join(path) unless path.absolute?
          path.unlink
        end
      end

      class Mysql < Storage
        def _create
          execute("CREATE DATABASE #{database}")
        end

        def _drop
          execute("DROP DATABASE #{database}")
        end

      private

        def execute(command)
          `mysql --user=#{username} #{password.blank? ? '' : "--password=#{password}"} -e "#{command}"`
        end

      end

      class Postgres < Storage
        def _create
          `createdb -U #{username} #{database}`
        end

        def _drop
          `dropdb -U #{username} #{database}`
        end
      end

    end
  end
end
