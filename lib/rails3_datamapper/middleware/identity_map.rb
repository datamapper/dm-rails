module Rails
  module DataMapper
    module Middleware

      class IdentityMap
        def initialize(app)
          @app = app
        end

        def call(env)
          ::DataMapper.repository do
            @app.call(env)
          end
        end
      end

    end
  end
end
