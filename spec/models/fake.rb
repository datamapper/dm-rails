module Rails; module DataMapper; module Models
  class Composite
    attr_accessor :args

    def initialize(*args)
      @args = args
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      !other.nil? && other.args == args
    end
  end

  class Fake
    super_module = Module.new do
      def _super_attributes=(*args)
      end

      def attributes=(*args)
        self.send(:_super_attributes=, *args)
      end

      def properties
      end
    end
    include super_module

    include ::Rails::DataMapper::MultiparameterAttributes
  end
end; end; end
