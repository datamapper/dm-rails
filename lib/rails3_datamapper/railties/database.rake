require 'rails3_datamapper/setup'
require 'rails3_datamapper/storage'

namespace :db do

  task :load_config => :rails_env do
    Rails::DataMapper.configurations = Rails::Configuration.new.database_configuration
  end

  task :load_models => :environment do
    FileList["app/models/**/*.rb"].each { |model| load model }
  end


  namespace :create do
    desc 'Create all the local databases defined in config/database.yml'
    task :all => :load_config do
      Rails::DataMapper::Storage.create_local_databases
    end
  end

  desc "Create the database"
  task :create => :load_config do
    Rails::DataMapper::Storage.create_database(Rails::DataMapper.configurations[Rails.env])
  end

  namespace :drop do
    desc 'Drop all the local databases defined in config/database.yml'
    task :all => :load_config do
      Rails::DataMapper::Storage.drop_local_databases
    end
  end

  desc "Drop the database"
  task :drop => :load_config do
    Rails::DataMapper::Storage.drop_database(Rails::DataMapper.configurations[Rails.env])
  end


  desc 'Perform destructive automigration'
  task :automigrate => :load_models do
    ::DataMapper.auto_migrate!
  end

  desc 'Perform non destructive automigration'
  task :autoupgrade => :load_models do
    ::DataMapper.auto_upgrade!
  end


  namespace :migrate do
    task :load => :environment do
      require 'dm-migrations'
      FileList['db/migrations/*.rb'].each do |migration|
        load migration
      end
    end

    desc 'Migrate up using migrations'
    task :up, :version, :needs => :load do |t, args|
      migrate_up!(args[:version])
    end

    desc 'Migrate down using migrations'
    task :down, :version, :needs => :load do |t, args|
      migrate_down!(args[:version])
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

  desc 'Create the database, load the schema, and initialize with the seed data'
  task :setup => [ 'db:create', 'db:automigrate', 'db:seed' ]

  desc 'Load the seed data from db/seeds.rb'
  task :seed => :environment do
    seed_file = File.join(Rails.root, 'db', 'seeds.rb')
    load(seed_file) if File.exist?(seed_file)
  end

end
