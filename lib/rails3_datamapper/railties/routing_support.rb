module Rails
  module DataMapper

    module RoutingSupport
      def to_param; id end
    end

  end
end
