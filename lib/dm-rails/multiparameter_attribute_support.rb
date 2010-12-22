module Rails
  module DataMapper
    module MultiparameterAttribute
      def self.included(model)
        model.alias_method_chain :attributes=, :multiparameter
      end

      protected
      def attributes_with_multiparameter=(values_hash)
        attribs = values_hash.dup
        multi_parameter_attributes = []
        attribs.each do |k, v|
          if k.to_s.include?("(")
            multi_parameter_attributes << [ k, v ]
            attribs.delete(k)
          # else
          #   respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(ArgumentError, "unknown property: #{k}")
          end
        end

        attribs = attribs.merge(assign_multiparameter_attributes(multi_parameter_attributes))

        self.attributes_without_multiparameter = attribs
      end

      def assign_multiparameter_attributes(pairs)
        execute_callstack_for_multiparameter_attributes(
          extract_callstack_for_multiparameter_attributes(pairs)
        )
      end

      def instantiate_time_object(name, values)
        if properties[name].name.demodulize =~ /utc/i
          Time.zone.local(*values)
        else
          Time.time_with_datetime_fallback(Rails.configuration.time_zone, *values)
        end
      end

      def execute_callstack_for_multiparameter_attributes(callstack)
        errors = []
        attribs = {}
        callstack.each do |name, values|
          klass = properties[name].primitive
          if values.empty?
            attribs[name] = nil
          else
            begin
              value = if Time == klass || DateTime == klass
                instantiate_time_object(name, values)
              elsif Date == klass
                begin
                  Date.new(*values)
                rescue ArgumentError => ex # if Date.new raises an exception on an invalid date
                  instantiate_time_object(name, values).to_date # we instantiate Time object and convert it back to a date thus using Time's logic in handling invalid dates
                end
              else
                klass.new(*values)
              end

              attribs[name] = value
            rescue => ex
              errors << "error on assignment #{values.inspect} to #{name}"
            end
          end
        end
        unless errors.empty?
          raise(ArgumentError, "#{errors.size} error(s) on assignment of multiparameter attributes")
        end
        attribs
      end

      def extract_callstack_for_multiparameter_attributes(pairs)
        attributes = { }

        for pair in pairs
          multiparameter_name, value = pair
          attribute_name = multiparameter_name.split("(").first
          attributes[attribute_name] = [] unless attributes.include?(attribute_name)

          unless value.empty?
            attributes[attribute_name] <<
              [ find_parameter_position(multiparameter_name), type_cast_attribute_value(multiparameter_name, value) ]
          end
        end

        attributes.each { |name, values| attributes[name] = values.sort_by{ |v| v.first }.collect { |v| v.last } }
      end


      def type_cast_attribute_value(multiparameter_name, value)
        multiparameter_name =~ /\([0-9]*([a-z])\)/ ? value.send("to_" + $1) : value
      end

      def find_parameter_position(multiparameter_name)
        multiparameter_name.scan(/\(([0-9]*).*\)/).first.first
      end

    end # Model
  end

end

DataMapper::Model.append_inclusions(Rails::DataMapper::MultiparameterAttribute)
