require 'dm-core'
require 'dm-active_model'

require 'rails3_datamapper/config'

# Comment taken from active_record/railtie.rb
#
# For now, action_controller must always be present with
# rails, so let's make sure that it gets required before
# here. This is needed for correctly setting up the middleware.
# In the future, this might become an optional require.
require 'action_controller/railtie'
require 'rails'


module Rails
  module DataMapper

    module RoutingSupport

      # I'm not sure wether this is active_model related or not
      # but I can't remember any mention of #to_param in that
      # context. If it is, this is probably better placed in
      # dm-active_model, but for now it's fine to put it here.
      # If this is not present, action_view helpers seem to be
      # unable to identify a resource in routes
      def to_param
        id
      end

    end

    class Railtie < Rails::Railtie

      plugin_name :data_mapper

      rake_tasks do
        load 'rails3_datamapper/railties/database.rake'
      end

      initializer 'data_mapper.setup_repositories' do |app|
        Rails::DataMapper::Config.setup_repositories
      end

      initializer 'data_mapper.logger' do
        ::DataMapper.logger = Rails.logger
      end

    end

  end
end

DataMapper::Model.append_inclusions(Rails::DataMapper::RoutingSupport)
