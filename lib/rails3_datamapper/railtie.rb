module Rails
  module DataMapper
    class Railtie < Rails::Railtie
      plugin_name :data_mapper
      include_modules_in 'DataMapper::Resource'

      rake_tasks do
        load 'rails3_datamapper/railties/databases.rake'
      end

      initializer 'data_mapper.setup_repositories' do |app|
        Rails::DataMapper::Config.setup_repositories
      end

      initializer 'data_mapper.logger' do
        DataMapper::Logger.new(Rails.logger)
      end
    end # class Railtie
  end # module DataMapper
end # module Rails
