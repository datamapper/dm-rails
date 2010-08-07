require 'active_support/core_ext/module/attr_internal'

module Rails
  module DataMapper
    module Railties

      module ControllerRuntime

        extend ActiveSupport::Concern

        protected

        attr_internal :db_runtime

        def cleanup_view_runtime
          # TODO add checks if DataMapper is connected to a repository.
          # If it is, do this, if it isn't, just delegate to super
          db_rt_before_render = ::DataMapper::Railties::LogSubscriber.reset_runtime
          runtime = super
          db_rt_after_render = ::DataMapper::Railties::LogSubscriber.reset_runtime
          self.db_runtime = db_rt_before_render + db_rt_after_render
          runtime - db_rt_after_render
        end

        def append_info_to_payload(payload)
          super
          payload[:db_runtime] = db_runtime
        end


        module ClassMethods

          def log_process_action(payload)
            messages, db_runtime = super, payload[:db_runtime]
            messages << ("Models: %.3fms" % db_runtime.to_f) if db_runtime
            messages
          end

        end

      end

    end
  end
end

