require 'dm-core'
require 'active_support/core_ext/class/attribute'
require 'active_support/concern'
require 'active_model'

module ActiveModel
  module MassAssignmentSecurity
    # Provides a patched version of the Sanitizer used in Rails to handle property
    # and relationship objects as keys. There is no way to inject a custom sanitizer
    # without reimplementing the permission sets.
    module Sanitizer
      # Returns all attributes not denied by the authorizer.
      #
      # @param [Hash{Symbol,String,::DataMapper::Property,::DataMapper::Relationship=>Object}] attributes
      #   Names and values of attributes to sanitize.
      # @return [Hash]
      #   Sanitized hash of attributes.
      def sanitize(attributes)
        sanitized_attributes = attributes.reject do |key, value|
          key_name = key.name rescue key
          deny?(key_name)
        end
        debug_protected_attribute_removal(attributes, sanitized_attributes)
        sanitized_attributes
      end
    end
  end
end

module DataMapper
  # Include this module into a DataMapper model to enable ActiveModel's mass
  # assignment security.
  #
  # To use second parameter of {#attributes=} make sure to include this module
  # last.
  module MassAssignmentSecurity
    extend ::ActiveSupport::Concern
    include ::ActiveModel::MassAssignmentSecurity

    module ClassMethods
      extend ::ActiveModel::MassAssignmentSecurity::ClassMethods

      def logger
        @logger ||= ::DataMapper.logger
      end
    end

    # Sanitizes the specified +attributes+ according to the defined mass-assignment
    # security rules and calls +super+ with the result.
    #
    # Use either +attr_accessible+ to specify which attributes are allowed to be
    # assigned via {#attributes=}, or +attr_protected+ to specify which attributes
    # are *not* allowed to be assigned via {#attributes=}.
    #
    # +attr_accessible+ and +attr_protected+ are mutually exclusive.
    #
    # @param [Hash{Symbol,String,::DataMapper::Property,::DataMapper::Relationship=>Object}] attributes
    #   Names and values of attributes to sanitize.
    # @param [Boolean] guard_protected_attributes
    #   Determines whether mass-security rules are applied (when +true+) or not.
    # @return [Hash]
    #   Sanitized hash of attributes.
    # @api public
    #
    # @example [Usage]
    #   class User
    #     include DataMapper::Resource
    #     include DataMapper::MassAssignmentSecurity
    #
    #     property :name, String
    #     property :is_admin, Boolean
    #
    #     # Only allow name to be set via #attributes=
    #     attr_accessible :name
    #   end
    #
    #   user = User.new
    #   user.attributes = { :username => 'Phusion', :is_admin => true }
    #   user.username  # => "Phusion"
    #   user.is_admin  # => false
    #
    #   user.send(:attributes=, { :username => 'Phusion', :is_admin => true }, false)
    #   user.is_admin  # => true
    def attributes=(attributes, guard_protected_attributes = true)
      attributes = sanitize_for_mass_assignment(attributes) if guard_protected_attributes
      super(attributes)
    end
  end
end
