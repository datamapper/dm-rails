module DataMapper
  module Adapters
    module Benchmarking

      %w(create read update delete).each do |method|

        define_method method do |*args, &block|
          result = nil
          @runtime ||= 0
          @runtime += Benchmark.ms { result = super }
          result
        end
      end

      def reset_runtime
        rt, @runtime = @runtime, 0
        rt.to_f
      end

    end
  end
end
