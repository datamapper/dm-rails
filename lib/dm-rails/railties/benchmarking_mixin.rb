module DataMapper
  module Adapters
    module Benchmarking

      %w[ create read update delete ].each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__
          def #{method}(*args, &block)
            result = nil
            @runtime ||= 0
            @runtime += Benchmark.ms { result = super(*args, &block) }
            result
          end
        RUBY
      end

      def reset_runtime
        rt, @runtime = @runtime, 0
        rt.to_f
      end

    end
  end
end
