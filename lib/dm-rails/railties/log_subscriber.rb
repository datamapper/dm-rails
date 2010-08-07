module DataMapper
  module Railties

    class LogSubscriber < ActiveSupport::LogSubscriber

      def self.runtime=(value)
        Thread.current["data_mapper_sql_runtime"] = value
      end

      def self.runtime
        Thread.current["data_mapper_sql_runtime"] ||= 0
      end

      def self.reset_runtime
        rt, self.runtime = runtime, 0
        rt
      end

      def initialize
        super
        @odd_or_even = false
      end

      def sql(event)
        self.class.runtime += event.duration
        return unless logger.debug?

        name = '%s (%.1fms)' % [event.payload[:name], event.duration]
        sql  = event.payload[:sql].squeeze(' ')

        if odd?
          name = color(name, CYAN, true)
          sql  = color(sql, nil, true)
        else
          name = color(name, MAGENTA, true)
        end

        debug "  #{name}  #{sql}"
      end

      def odd?
        @odd_or_even = !@odd_or_even
      end

      def logger
        ::DataMapper.logger
      end

    end

  end
end
