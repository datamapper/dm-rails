require 'dm-core'
require 'active_support/core_ext/class/attribute'
require 'active_support/concern'
require 'active_model'

module ActiveModel
  module MassAssignmentSecurity
    module Sanitizer
      # Returns all attributes not denied by the authorizer. Property keys can
      # be a Symbol, String, DataMapper::Property, or DataMapper::Relationship
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
  # = Active Model Mass-Assignment Security
  module MassAssignmentSecurity
    extend ::ActiveSupport::Concern
    include ::ActiveModel::MassAssignmentSecurity

    module ClassMethods
      extend ::ActiveModel::MassAssignmentSecurity::ClassMethods

      def logger
        @logger ||= ::DataMapper.logger
      end

    end

    # Allows you to set all the attributes at once by passing in a hash with keys
    # matching the attribute names (which again matches the column names).
    #
    # If +guard_protected_attributes+ is true (the default), then sensitive
    # attributes can be protected from this form of mass-assignment by using
    # the +attr_protected+ macro. Or you can alternatively specify which
    # attributes *can* be accessed with the +attr_accessible+ macro. Then all the
    # attributes not included in that won't be allowed to be mass-assigned.
    #
    #   class User < ActiveRecord::Base
    #     attr_protected :is_admin
    #   end
    #
    #   user = User.new
    #   user.attributes = { :username => 'Phusion', :is_admin => true }
    #   user.username   # => "Phusion"
    #   user.is_admin?  # => false
    #
    #   user.send(:attributes=, { :username => 'Phusion', :is_admin => true }, false)
    #   user.is_admin?  # => true
    def attributes=(attributes, guard_protected_attributes = true)
      attributes = sanitize_for_mass_assignment(attributes) if guard_protected_attributes
      super(attributes)
    end

  end
end

