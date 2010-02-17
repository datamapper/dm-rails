module Rails
  module DataMapper

    module RoutingSupport

      # TODO think about supporting composite keys
      def to_param
        unless self.key.size == 1
          raise ArgumentError, 'Routing of resources with composite keys is currently not supported'
        end
        self.key.to_s
      end

    end

  end
end
