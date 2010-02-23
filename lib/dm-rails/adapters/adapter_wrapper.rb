module DataMapper
  module Adapters
    module Wrapper

      def self.included(host)
        host.class_eval do
          instance_methods.each do |method|
            next if method =~ /\A__/ || %w[
              send class dup object_id kind_of? instance_of? respond_to? equal? freeze frozen?
              should should_not instance_variables instance_variable_set instance_variable_get
              instance_variable_defined? remove_instance_variable extend hash inspect copy_object
            ].include?(method.to_s)
            undef_method method
          end
          include InstanceMethods
          attr_reader :adapter
        end
      end

      module InstanceMethods

        def kind_of?(klass)
          super || adapter.kind_of?(klass)
        end

        def instance_of?(klass)
          super || adapter.instance_of?(klass)
        end

        def respond_to?(method, include_private = false)
          super || adapter.respond_to?(method, include_private)
        end

        private

        def initialize(adapter)
          @adapter = adapter
        end

        def method_missing(method, *args, &block)
          adapter.send(method, *args, &block)
        end

      end

    end
  end
end
