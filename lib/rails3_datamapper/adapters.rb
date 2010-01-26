require 'rails3_datamapper/adapters/benchmarking_adapter'

module Rails
  module DataMapper
    module Adapters

      class Cascade

        def self.configure
          block_given? ? yield(cascade) : cascade
        end

        def self.instantiate(adapter, idx = 0)
          if idx < cascade.size
            instantiate(cascade[idx], idx + 1).new(adapter)
          else
            adapter
          end
        end

        def self.cascade
          @cascade ||= new
        end


        def push(adapter)
          @cascade << adapter
        end

        alias :use :push

        def size;    @cascade.size end
        def [](idx); @cascade[idx] end

        private

        def initialize
          @cascade, @adapter = [], nil
        end

      end

    end
  end
end
