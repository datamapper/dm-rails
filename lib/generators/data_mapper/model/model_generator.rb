require 'generators/data_mapper'

module Rails
  module DataMapper
    module Generators

      class ModelGenerator < Base
        argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
        class_option :id, :type => :numeric, :desc => "The id to be used in the migration"

        check_class_collision

        class_option :timestamps, :type => :boolean
        class_option :parent,     :type => :string, :desc => "The parent class for the generated model"

        def create_model_file
          template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
        end

        hook_for :test_framework

      end

    end
  end
end