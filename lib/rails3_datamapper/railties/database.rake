require 'rails3_datamapper/config'

namespace :db do

  desc "Create the database"
  task :create do
    config = Rails::DataMapper::Config.config
    database = config[:database] || config[:path]
    puts "Creating database '#{database}'"
    case config[:adapter]
    when 'postgres'
      `createdb -U #{config[:username]} #{database}`
    when 'mysql'
      user, password = config[:username], config[:password]
      `mysql -u #{user} #{password ? "-p #{password}" : ''} -e "create database #{database}"`
    when 'sqlite3'
      Rake::Task['rake:db:automigrate'].invoke
    else
      raise "Adapter #{config[:adapter]} not supported for creating databases yet."
    end
  end

  desc "Drop the database (postgres and mysql only)"
  task :drop do
    config   = Rails::DataMapper::Config.config
    database = config[:database] || config[:path]
    puts "Dropping database '#{database}'"
    case config[:adapter]
    when 'postgres'
      `dropdb -U #{config[:username]} #{database}`
    when 'mysql'
      user, password = config[:username], config[:password]
      `mysql -u #{user} #{password ? "-p #{password}" : ''} -e "drop database #{database}"`
    when 'sqlite3'
      require 'pathname'
      path = Pathname.new(config['database'])
      file = path.absolute? ? path.to_s : File.join(Rails.root, path)
      FileUtils.rm(file)
    else
      raise "Adapter #{config[:adapter]} not supported for dropping databases yet.\ntry db:automigrate"
    end
  end

  desc 'Perform automigration'
  task :automigrate => :environment do
    FileList["app/models/**/*.rb"].each do |model|
      load model
    end
    ::DataMapper.auto_migrate!
  end

  desc 'Perform non destructive automigration'
  task :autoupgrade => :environment do
    FileList["app/models/**/*.rb"].each do |model|
      load model
    end
    ::DataMapper.auto_upgrade!
  end

  namespace :migrate do
    task :load => :environment do
      gem 'dm-migrations', '0.10.2'
      FileList['db/migrations/*.rb'].each do |migration|
        load migration
      end
    end

    desc 'Migrate up using migrations'
    task :up, :version, :needs => :load do |t, args|
      version = args[:version]
      migrate_up!(version)
    end

    desc 'Migrate down using migrations'
    task :down, :version, :needs => :load do |t, args|
      version = args[:version]
      migrate_down!(version)
    end
  end

  desc 'Migrate the database to the latest version'
  task :migrate => 'db:migrate:up'

  namespace :sessions do
    desc "Creates the sessions table for DataMapperStore"
    task :create => :environment do
      ::DataMapperStore::Session.auto_migrate!
    end

    desc "Clear the sessions table for DataMapperStore"
    task :clear => :environment do
      ::DataMapperStore::Session.all.destroy!
    end
  end
end
