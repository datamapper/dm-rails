require 'rails3_datamapper/setup'
require 'rails3_datamapper/storage'

namespace :db do

  task :load_models => :environment do
    FileList["app/models/**/*.rb"].each { |model| load model }
  end

  desc 'Create the database, load the schema, and initialize with the seed data'
  task :setup => [ 'db:create', 'db:automigrate', 'db:seed' ]

  namespace :create do
    desc 'Create all the local databases defined in config/database.yml'
    task :all => :environment do
      Rails::DataMapper.storage.create_all
    end
  end

  desc "Create the database(s) defined in config/database.yml for the current Rails.env - also creates the test database(s) if Rails.env.development?"
  task :create => :environment do
    Rails::DataMapper.storage.create_environment(Rails::DataMapper.configuration.repositories[Rails.env])
    if Rails.env.development? && Rails::DataMapper.configuration.repositories['test']
      Rails::DataMapper.storage.create_environment(Rails::DataMapper.configuration.repositories['test'])
    end
  end

  namespace :drop do
    desc 'Drop all the local databases defined in config/database.yml'
    task :all => :environment do
      Rails::DataMapper.storage.drop_all
    end
  end

  desc "Drops the database(s) for the current Rails.env - also drops the test database(s) if Rails.env.development?"
  task :drop => :environment do
    Rails::DataMapper.storage.drop_environment(Rails::DataMapper.configuration.repositories[Rails.env])
    if Rails.env.development? && Rails::DataMapper.configuration.repositories['test']
      Rails::DataMapper.storage.drop_environment(Rails::DataMapper.configuration.repositories['test'])
    end
  end


  desc 'Perform destructive automigration'
  task :automigrate => :load_models do
    ::DataMapper.auto_migrate!
  end

  desc 'Perform non destructive automigration'
  task :autoupgrade => :load_models do
    ::DataMapper.auto_upgrade!
  end

  desc 'Load the seed data from db/seeds.rb'
  task :seed => :environment do
    seed_file = File.join(Rails.root, 'db', 'seeds.rb')
    load(seed_file) if File.exist?(seed_file)
  end

  namespace :migrate do
    task :load => :environment do
      require 'dm-migrations/migration_runner'
      FileList['db/migrate/*.rb'].each do |migration|
        load migration
      end
    end

    desc 'Migrate up using migrations'
    task :up, :version, :needs => :load do |t, args|
      ::DataMapper::MigrationRunner.migrate_up!(args[:version])
    end

    desc 'Migrate down using migrations'
    task :down, :version, :needs => :load do |t, args|
      ::DataMapper::MigrationRunner.migrate_down!(args[:version])
    end
  end

  desc 'Migrate the database to the latest version'
  task :migrate => 'db:migrate:up'

  namespace :sessions do
    desc "Creates the sessions table for DataMapperStore"
    task :create => :environment do
      require 'rails3_datamapper/session_store'
      Rails::DataMapper::SessionStore::Session.auto_migrate!
      puts "Created '#{Rails::DataMapper.configurations[Rails.env]['database']}.sessions'"
    end

    desc "Clear the sessions table for DataMapperStore"
    task :clear => :environment do
      require 'rails3_datamapper/session_store'
      Rails::DataMapper::SessionStore::Session.all.destroy!
      puts "Deleted entries from '#{Rails::DataMapper.configurations[Rails.env]['database']}.sessions'"
    end
  end

end
