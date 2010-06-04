require 'active_support/notifications'

# TODO This needs to be fixed upstream in active_support/notifications/instrumenter.rb
#
# We need to monkeypatch this for now, because the original implementation hardcodes the
# duration to the time elapsed between start and end of the event. The current upstream
# implementation is included here for reference:
#
#   def duration
#     @duration ||= 1000.0 * (@end - @time)
#   end
#
# It should be safe to assume that explicitly provided duration information should be at
# least as precise as the current generic solution, if not more (as in our specific case).
#
module ActiveSupport
  module Notifications
    class Event
      def duration
        @duration ||= payload[:duration] ? (payload[:duration] / 1000.0) : 1000.0 * (@end - @time)
      end
    end
  end
end

module LogListener
  def log(message)
    ActiveSupport::Notifications.instrument('sql.data_mapper',
      :name          => 'SQL',
      :sql           => message.query, # TODO think about changing the key to :query
      :start         => message.start,
      :duration      => message.duration,
      :connection_id => self.object_id
    )
    super
  rescue Exception => e
    ::DataMapper.logger.error "[datamapper] #{e.class.name}: #{e.message}: #{message.inspect}}"
  end
end
