require 'rails3_datamapper/adapters/benchmarking_adapter'

module Rails
  module DataMapper
    module Adapters

      class Cascade

        def self.setup(base_adapter)
          cascade.instantiate(base_adapter)
        end

        def self.push(adapter)
          cascade.push(adapter)
        end

        def self.cascade
          @cascade ||= new
        end


        def instantiate(adapter, idx = 0)
          if idx < @cascade.size
            instantiate(@cascade[idx], idx + 1).new(adapter)
          else
            adapter
          end
        end

        def push(adapter)
          @cascade << adapter
        end

        private

        def initialize
          @cascade, @adapter = [], nil
        end

      end

    end
  end
end
