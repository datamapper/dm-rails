require 'dm-core'
require 'active_support/core_ext/class/attribute'

# Implements DataMapper-specific session store.

module Rails
  module DataMapper

    class SessionStore < ActionDispatch::Session::AbstractStore

      class Session

        include ::DataMapper::Resource

        property :id,         Serial
        property :session_id, String,   :required => true, :unique => true
        property :data,       Object,   :required => true
        property :updated_at, DateTime,                    :index => true

        def self.name
          'session'
        end

        def data
          attribute_get(:data) || {}
        end

      end

      SESSION_RECORD_KEY = 'rack.session.record'.freeze

      class_attribute :session_class
      self.session_class = Session

      private

      def get_session(env, sid)
        sid ||= generate_sid
        session = find_session(sid)
        env[SESSION_RECORD_KEY] = session
        [ sid, session.data ]
      end

      def set_session(env, sid, session_data)
        session            = get_session_resource(env, sid)
        session.data       = session_data
        session.updated_at = DateTime.now if session.dirty?
        session.save ? sid : false
      end

      def get_session_resource(env, sid)
        if env[ENV_SESSION_OPTIONS_KEY][:id].nil?
          env[SESSION_RECORD_KEY] = find_session(sid)
        else
          env[SESSION_RECORD_KEY] ||= find_session(sid)
        end
      end

      def find_session(sid)
        self.class.session_class.first_or_new(:session_id => sid)
      end

      def destroy(env)
        find_session(current_session_id(env)).destroy
      end

    end

  end
end
