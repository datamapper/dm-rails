require 'spec_helper'
require 'dm-rails/mass_assignment_security'

if defined?(DataMapper::MassAssignmentSecurity)
  # Because mass-assignment security is based on ActiveModel we just have to
  # ensure that ActiveModel is called.
  describe DataMapper::MassAssignmentSecurity do
    before :all do
      class Fake
        super_module = Module.new do
          def _super_attributes=(*args)
          end

          def attributes=(*args)
            self.send(:_super_attributes=, *args)
          end
        end
        include super_module

        include ::DataMapper::MassAssignmentSecurity
      end
    end

    describe '#attributes=' do
      it 'calls super with sanitized attributes' do
        attributes = { :name => 'John', :is_admin => true }
        sanitized_attributes = { :name => 'John' }
        model = Fake.new
        model.should_receive(:sanitize_for_mass_assignment).with(attributes).and_return(sanitized_attributes)
        model.should_receive(:_super_attributes=).with(sanitized_attributes)

        model.attributes = attributes
      end

      it 'skips sanitation when called with true' do
        attributes = { :name => 'John', :is_admin => true }
        sanitized_attributes = { :name => 'John' }
        model = Fake.new
        model.should_receive(:_super_attributes=).with(attributes)

        model.send(:attributes=, attributes, true)
      end
    end
  end
end
