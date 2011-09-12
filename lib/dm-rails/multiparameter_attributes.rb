require 'active_support/core_ext/module/aliasing'

module Rails
  module DataMapper
    # Encapsulates an error of a multiparameter assignment.
    class MultiparameterAssignmentError < StandardError
      # Gets the target attribute of the assignment.
      # @return [String]
      attr_reader :attribute

      # Gets the assigned values.
      # @return [Array]
      attr_reader :values

      # Gets the exception raised on the assignment.
      # @return [Exception]
      attr_reader :exception

      # Initializes a new instance of the {MultiparameterAssignmentError} class.
      #
      # @param [String] attribute The target attribute of the assignment.
      # @param [Array] values The assigned values.
      # @param [Exception] exception The exception raised on the assignment.
      def initialize(attribute, values, exception)
        super("Could not assign #{values.inspect} to #{attribute} (#{exception.message}).")
        @attribute = attribute
        @values = values
        @exception = exception
      end
    end

    # Raised by {MultiparameterAttributes#attributes=} when there are errors when
    # merging multiparameter attributes. Use {#errors} to get the array of errors
    # occured.
    class MultiparameterAssignmentErrors < StandardError
      # Gets the array of assignment errors.
      # @return [Array<MultiparameterAssignmentError>]
      attr_reader :errors

      # Initializes a new instance of the {MultiparameterAssignmentErrors} class.
      #
      # @param [Array<MultiparameterAssignmentError>] errors
      #   The array of assignment errors.
      # @param [String] message Optional error message.
      def initialize(errors, message = nil)
        super(message || "#{errors.size} error#{errors.size == 1 ? '' : 's'} on assignment of multiparameter attributes.")
        @errors = errors
      end
    end

    # Include this module into a DataMapper model to enable multiparameter
    # attributes.
    #
    # A multiparameter attribute has +attr(Xc)+ as name where +attr+ specifies
    # the attribute, +X+ the position of the value, and +c+ an optional typecast
    # identifier. All values that share an +attr+ are sorted by their position,
    # optionally cast using +#to_c+ (where +c+ is the typecast identifier) and
    # then used to instantiate the proper attribute value.
    #
    # @example
    #   # Assigning a hash with multiparameter values for a +Date+ property called
    #   # +written_on+:
    #   resource.attributes = {
    #       'written_on(1i)' => '2004',
    #       'written_on(2i)' => '6',
    #       'written_on(3i)' => '24' }
    #
    #   # +Date+ will be initialized with each string cast to a number using
    #   # #to_i.
    #   resource.written_on == Date.new(2004, 6, 24)
    module MultiparameterAttributes
      # Merges multiparameter attributes and calls +super+ with the merged
      # attributes.
      #
      # @param [Hash{String,Symbol=>Object}] attributes
      #   Names and values of attributes to assign.
      # @return [Hash]
      #   Names and values of attributes assigned.
      # @raise [MultiparameterAssignmentErrors]
      #   One or more multiparameters could not be assigned.
      # @api public
      def attributes=(attributes)
        attribs = attributes.dup
        multi_parameter_attributes = []
        attribs.each do |k, v|
          if k.to_s.include?("(")
            multi_parameter_attributes << [ k, v ]
            attribs.delete(k)
          end
        end

        attribs.merge!(merge_multiparameter_attributes(multi_parameter_attributes))
        super(attribs)
      end

    protected
      def merge_multiparameter_attributes(pairs)
        pairs = extract_multiparameter_attributes(pairs)

        errors = []
        attributes = {}
        pairs.each do |name, values_with_empty_parameters|
          # ActiveRecord keeps the empty values to set dates without a year.
          # Removing all nils (instead of removing only trailing nils) seems
          # like a weird behavior though.
          values = values_with_empty_parameters.compact

          if values.empty?
            attributes[name] = nil
            next
          end

          klass = properties[name].dump_class
          begin
            attributes[name] =
              if klass == Time
                Time.local(*values)
              elsif klass == Date
                # Date does not replace nil values with defaults.
                Date.new(*values_with_empty_parameters.map { |v| v.nil? ? 1 : v })
              else
                klass.new(*values)
              end
          rescue => ex
            errors << MultiparameterAssignmentError.new(name, values, ex)
          end
        end

        unless errors.empty?
          raise MultiparameterAssignmentErrors.new(errors)
        end

        attributes
      end

      def extract_multiparameter_attributes(pairs)
        attributes = {}

        for multiparameter_name, value in pairs
          unless multiparameter_name =~ /\A ([^\)]+) \(  ([0-9]+) ([a-z])?  \) \z/x
            raise "Invalid multiparameter name #{multiparameter_name.inspect}."
          end

          name, position, typecast = $1, $2, $3
          attributes[name] ||= []

          parameter_value =
            if value.empty?
              nil
            elsif typecast
              value.send('to_' + typecast)
            else
              value
            end

          attributes[name] << [ position, parameter_value ]
        end

        # Order each parameter array according to the position, then discard the
        # position.
        attributes.each { |name, values|
          attributes[name] = values.sort_by{ |v| v.first }.collect { |v| v.last }
        }
      end
    end # MultiparameterAttributes
  end
end
