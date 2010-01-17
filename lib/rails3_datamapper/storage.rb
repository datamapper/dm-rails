module Rails
  module DataMapper

    module Storage

      def self.create_local_databases
        with_local_databases { |config| create_database(config) }
      end

      def self.drop_local_databases
        with_local_databases { |config| drop_database(config) }
      end


      def self.create_database(config)
        database = config['database'] || config['path']
        puts "Creating database '#{database}'"
        case config['adapter']
        when 'postgres'
          `createdb -U #{config['username']} #{database}`
        when 'mysql'
          user, password = config['username'], config['password']
          `mysql -u #{user} #{password ? "-p #{password}" : ''} -e "create database #{database}"`
        when 'sqlite3'
          Rails::DataMapper.setup(config)
        else
          raise "Adapter #{config['adapter']} not supported for creating databases yet."
        end
      end

      def self.drop_database(config)
        database = config['database'] || config['path']
        puts "Dropping database '#{database}'"
        case config['adapter']
        when 'postgres'
          `dropdb -U #{config['username']} #{database}`
        when 'mysql'
          user, password = config['username'], config['password']
          `mysql -u #{user} #{password ? "-p #{password}" : ''} -e "drop database #{database}"`
        when 'sqlite3'
          require 'pathname'
          path = Pathname.new(config['database'])
          file = path.absolute? ? path.to_s : File.join(Rails.root, path)
          FileUtils.rm(file)
        else
          raise "Adapter #{config['adapter']} not supported for dropping databases yet.\ntry db:automigrate"
        end
      end


      # Skips entries that don't have a database key, such as the first entry here:
      #
      #  defaults: &defaults
      #    adapter: mysql
      #    username: root
      #    password:
      #    host: localhost
      #
      #  development:
      #    database: blog_development
      #    <<: *defaults
      def self.with_local_databases
        Rails::DataMapper.configurations.each_value do |config|
          next unless config['database']
          with_local_database(config) { yield(config) }
        end
      end

      def self.with_local_database(config, &block)
        if %w( 127.0.0.1 localhost ).include?(config['host']) || config['host'].blank?
          yield
        else
          puts "This task only modifies local databases. #{config['database']} is on a remote host."
        end
      end

    end
    
  end
end