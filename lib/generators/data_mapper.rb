require 'rails/generators/named_base'
require 'rails/generators/migration'
require 'rails/generators/active_model'
require 'dm-core'

module DataMapper
  module Generators
    class Base < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      # Automatically sets the source root based on the class name.
      #
      def self.source_root
        @_rails_source_root ||= begin
          if base_name && generator_name
            File.expand_path(File.join(File.dirname(__FILE__), base_name, generator_name, 'templates'))
          end
        end
      end


      protected
        # Implement the required interface for Rails::Generators::Migration.
        #
        def next_migration_number(dirname) #:nodoc:
          "%.3d" % (current_migration_number(dirname) + 1)
        end
    end
  end
end
