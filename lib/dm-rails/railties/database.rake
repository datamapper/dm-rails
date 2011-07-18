require 'dm-rails/setup'
require 'dm-rails/storage'

namespace :db do

  desc 'Create the database, load the schema, and initialize with the seed data'
  task :setup => [ 'db:create', 'db:automigrate', 'db:seed' ]

  namespace :create do
    desc 'Create all the local databases defined in config/database.yml'
    task :all => :environment do
      Rails::DataMapper.storage.create_all
    end
  end

  desc "Create all local databases defined for the current Rails.env"
  task :create => :environment do
    Rails::DataMapper.storage.create_environment(Rails::DataMapper.configuration.repositories[Rails.env])
  end

  namespace :drop do
    desc 'Drop all the local databases defined in config/database.yml'
    task :all => :environment do
      Rails::DataMapper.storage.drop_all
    end
  end

  desc "Drop all local databases defined for the current Rails.env"
  task :drop => :environment do
    Rails::DataMapper.storage.drop_environment(Rails::DataMapper.configuration.repositories[Rails.env])
  end


  desc 'Perform destructive automigration of all repositories in the current Rails.env'
  task :automigrate => :environment do
    require 'dm-migrations'
    Rails::DataMapper.configuration.repositories[Rails.env].each do |repository, config|
      ::DataMapper.auto_migrate!(repository.to_sym)
      puts "[datamapper] Finished auto_migrate! for :#{repository} repository '#{config['database']}'"
    end
  end

  desc 'Perform non destructive automigration of all repositories in the current Rails.env'
  task :autoupgrade => :environment do
    require 'dm-migrations'
    Rails::DataMapper.configuration.repositories[Rails.env].each do |repository, config|
      ::DataMapper.auto_upgrade!(repository.to_sym)
      puts "[datamapper] Finished auto_upgrade! for :#{repository} repository '#{config['database']}'"
    end
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
    task :up, [:version] => [:load] do |t, args|
      ::DataMapper::MigrationRunner.migrate_up!(args[:version])
    end

    desc 'Migrate down using migrations'
    task :down, [:version] => [:load] do |t, args|
      ::DataMapper::MigrationRunner.migrate_down!(args[:version])
    end
  end

  desc 'Migrate the database to the latest version'
  task :migrate do
    migrate_task = if Dir['db/migrate/*.rb'].empty?
                     'db:autoupgrade'
                   else
                     'db:migrate:up'
                   end

    Rake::Task[migrate_task].invoke
  end

  namespace :sessions do
    desc "Creates the sessions table for DataMapperStore"
    task :create => :environment do
      require 'dm-rails/session_store'
      Rails::DataMapper::SessionStore::Session.auto_migrate!
      database = Rails::DataMapper.configuration.repositories[Rails.env]['database']
      puts "Created '#{database}.sessions'"
    end

    desc "Clear the sessions table for DataMapperStore"
    task :clear => :environment do
      require 'dm-rails/session_store'
      Rails::DataMapper::SessionStore::Session.destroy!
      database = Rails::DataMapper.configuration.repositories[Rails.env]['database']
      puts "Deleted entries from '#{database}.sessions'"
    end
  end

end
