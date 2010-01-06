module Rails
  module DataMapper
    class Plugin < Rails::Plugin
      plugin_name :data_mapper
      include_modules_in 'DataMapper::Resource'

      initializer 'data_mapper.setup_repositories' do |app|
        Rails::DataMapper::Config.setup_repositories
      end

      initializer 'data_mapper.logger' do
        DataMapper::Logger.new(Rails.logger)
      end
    end # class Plugin
  end # module DataMapper
end # module Rails
