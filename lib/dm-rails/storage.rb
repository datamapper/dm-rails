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
          klass_name = normalized_adapter_name(adapter).camelize.to_sym

          unless Storage.const_defined?(klass_name)
            raise "Adapter #{adapter} not supported (#{klass_name.inspect})"
          end

          const_get(klass_name)
        end

        def normalized_adapter_name(adapter_name)
          adapter_name.to_s == 'sqlite3' ? 'sqlite' : adapter_name
        end

      end

      def initialize(name, config)
        @name, @config = name.to_sym, config
      end

      def create
        puts create_message if _create
      end

      def drop
        puts drop_message if _drop
      end

      def database
        @database ||= config['database'] || config['path']
      end

      def username
        @username ||= config['username'] || ''
      end

      def password
        @password ||= config['password'] || ''
      end

      def charset
        @charset ||= config['charset'] || ENV['CHARSET'] || 'utf8'
      end

      def create_message
        "[datamapper] Created database '#{database}'"
      end

      def drop_message
        "[datamapper] Dropped database '#{database}'"
      end

      class Sqlite < Storage
        def _create
          # This is a noop for sqlite
          #
          # Both auto_migrate!/auto_upgrade! will create the actual database
          # if the connection has been setup properly and there actually
          # are statements to execute (i.e. at least one model is declared)
          #
          # DataMapper.setup alone won't create the actual database so there
          # really is no API to simply create an empty database for sqlite3.
          #
          # we return true to indicate success nevertheless

          true
        end

        def _drop
          return if in_memory?
          path.unlink if path.file?
        end

        def create_message
          "[datamapper] db:create is a noop for sqlite3, use db:automigrate instead (#{database})"
        end

      private

        def in_memory?
          database == ':memory:'
        end

        def path
          @path ||= Pathname(File.expand_path(database, Rails.root))
        end

      end

      class Mysql < Storage
        def _create
          execute("CREATE DATABASE `#{database}` DEFAULT CHARACTER SET #{charset} DEFAULT COLLATE #{collation}")
        end

        def _drop
          execute("DROP DATABASE IF EXISTS `#{database}`")
        end

      private

        def execute(statement)
          system(
            'mysql',
            (username.blank? ? '' : "--user=#{username}"),
            (password.blank? ? '' : "--password=#{password}"),
            '-e',
            statement
          )
        end

        def collation
          @collation ||= config['collation'] || ENV['COLLATION'] || 'utf8_unicode_ci'
        end

      end

      class Postgres < Storage
        def _create
          system(
            'createdb',
            '-E',
            charset,
            '-U',
            username,
            database
          )
        end

        def _drop
          system(
            'dropdb',
            '-U',
            username,
            database
          )
        end

      end
    end
  end
end
