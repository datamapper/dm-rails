module Rails
  module DataMapper

    def self.storage
      @storage ||= Storage.new
    end

    class Storage

      def create_all
        with_local_repositories { |config| create_environment(config) }
      end

      def drop_all
        with_local_repositories { |config| drop_environment(config) }
      end

      def create_environment(config)
        config.each { |repo_name, repo_config| create(repo_config) }
      end

      def drop_environment(config)
        config.each { |repo_name, repo_config| drop(repo_config) }
      end

      def create(config)
        database = config['database'] || config['path']
        puts "Creating database '#{database}'"
        case config['adapter']
        when 'postgres'
          `createdb -U #{config['username']} #{database}`
        when 'mysql'
          user, password = config['username'], config['password']
          `mysql --user=#{user} #{password ? "--password=#{password}" : ''} -e "create database #{database}"`
        when 'sqlite3'
          Rails::DataMapper.setup(config)
        else
          raise "Adapter #{config['adapter']} not supported for creating databases yet."
        end
      end

      def drop(config)
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


      def with_local_repositories
        Rails::DataMapper.configuration.repositories.each_value do |config|
          if %w( 127.0.0.1 localhost ).include?(config['host']) || config['host'].blank?
            yield(config)
          else
            puts "This task only modifies local databases. #{config['database']} is on a remote host."
          end
        end
      end

    end
    
  end
end