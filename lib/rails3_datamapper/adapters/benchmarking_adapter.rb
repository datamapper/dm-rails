require 'rails3_datamapper/adapters/adapter_wrapper'

module Rails
 module DataMapper
   module Adapters

     class BenchmarkingAdapter

       include ::DataMapper::Adapters::Wrapper

       def reset_runtime
         rt, @runtime = @runtime, 0
         rt
       end

       %w(create read update delete).each do |method|

         define_method method do |*args, &block|
           result = nil
           @runtime += Benchmark.ms { result = adapter.send(method, *args, &block) }
           result
         end

       end

       private

       def initialize(adapter)
         super
         @runtime = 0
       end

     end

   end
 end
end
