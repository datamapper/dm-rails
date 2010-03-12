require 'dm-rails/adapters/adapter_wrapper'

module Rails
 module DataMapper
   module Adapters

     class BenchmarkingAdapter

       include ::DataMapper::Adapters::Wrapper

       def reset_runtime
         rt, @runtime = @runtime, 0
         rt
       end

       %w[ create read update delete ].each do |method|
         class_eval <<-RUBY, __FILE__, __LINE__ + 1
           def #{method}(*args, &block)                    # def create(*args, &block)
             result = nil                                  #   result = nil
             @runtime += Benchmark.ms do                   #   @runtime += Benchmark.ms do
               result = adapter.#{method}(*args, &block)   #     result = adapter.create(*args, &block)
             end                                           #   end
             result                                        #   result
           end                                             # end
         RUBY
       end

       private

       def initialize(adapter)
         super
         reset_runtime
       end

     end

   end
 end
end
