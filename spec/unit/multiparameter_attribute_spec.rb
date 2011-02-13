require 'spec_helper'
require 'dm-rails/multiparameter_attribute_support'

# Since multiparameters are a feature of Rails some tests are based on the test
# suite of Rails.
describe Rails::DataMapper::MultiparameterAttribute do
  before :all do
    load Pathname(__FILE__).dirname.parent.join('models/topic.rb').expand_path
    load Pathname(__FILE__).dirname.parent.join('models/fake.rb').expand_path
    ::Rails::DataMapper::Models::Topic.auto_migrate!
  end

  describe '#attributes=' do
    date_inputs = [
      [ 'date',
        { 'last_read(1i)' => '2004', 'last_read(2i)' => '6', 'last_read(3i)' => '24' },
        Date.new(2004, 6, 24) ],
      [ 'date with empty year',
        { 'last_read(1i)' => '', 'last_read(2i)' => '6', 'last_read(3i)' => '24' },
        Date.new(1, 6, 24) ],
      [ 'date with empty month',
        { 'last_read(1i)' => '2004', 'last_read(2i)' => '', 'last_read(3i)' => '24' },
        Date.new(2004, 1, 24) ],
      [ 'date with empty day',
        { 'last_read(1i)' => '2004', 'last_read(2i)' => '6', 'last_read(3i)' => '' },
        Date.new(2004, 6, 1) ],
      [ 'date with empty day and year',
        { 'last_read(1i)' => '', 'last_read(2i)' => '6', 'last_read(3i)' => '' },
        Date.new(1, 6, 1) ],
      [ 'date with empty day and month',
        { 'last_read(1i)' => '2004', 'last_read(2i)' => '', 'last_read(3i)' => '' },
        Date.new(2004, 1, 1) ],
      [ 'date with empty year and month',
        { 'last_read(1i)' => '', 'last_read(2i)' => '', 'last_read(3i)' => '24' },
        Date.new(1, 1, 24) ],
      [ 'date with all empty',
        { 'last_read(1i)' => '', 'last_read(2i)' => '', 'last_read(3i)' => '' },
        nil ],
    ]

    date_inputs.each do |(name, attributes, date)|
      it "converts #{name}" do
        topic = ::Rails::DataMapper::Models::Topic.new
        topic.attributes = attributes
        topic.last_read.should == date
      end
    end

    time_inputs = [
      [ 'time',
        { 'written_on(1i)' => '2004', 'written_on(2i)' => '6', 'written_on(3i)' => '24',
          'written_on(4i)' => '16', 'written_on(5i)' => '24', 'written_on(6i)' => '00' },
        Time.local(2004, 6, 24, 16, 24, 0) ],
      [ 'time with old date',
        { 'written_on(1i)' => '1850', 'written_on(2i)' => '6', 'written_on(3i)' => '24',
          'written_on(4i)' => '16', 'written_on(5i)' => '24', 'written_on(6i)' => '00' },
        Time.local(1850, 6, 24, 16, 24, 0) ],
      [ 'time with all empty',
        { 'written_on(1i)' => '', 'written_on(2i)' => '', 'written_on(3i)' => '',
          'written_on(4i)' => '', 'written_on(5i)' => '', 'written_on(6i)' => '' },
        nil ],
      [ 'time with empty seconds',
        { 'written_on(1i)' => '2004', 'written_on(2i)' => '6', 'written_on(3i)' => '24',
          'written_on(4i)' => '16', 'written_on(5i)' => '24', 'written_on(6i)' => '' },
        Time.local(2004, 6, 24, 16, 24, 0) ],
    ]

    time_inputs.each do |(name, attributes, time)|
      it "converts #{name}" do
        topic = ::Rails::DataMapper::Models::Topic.new
        topic.attributes = attributes
        topic.written_on.should == time
      end
    end

    date_time_inputs = [
      [ 'datetime',
        { 'updated_at(1i)' => '2004', 'updated_at(2i)' => '6', 'updated_at(3i)' => '24',
          'updated_at(4i)' => '16', 'updated_at(5i)' => '24', 'updated_at(6i)' => '00' },
        DateTime.new(2004, 6, 24, 16, 24, 0) ],
    ]

    date_time_inputs.each do |(name, attributes, time)|
      it "converts #{name}" do
        topic = ::Rails::DataMapper::Models::Topic.new
        topic.attributes = attributes
        topic.updated_at.should == time
      end
    end

    it 'calls super with merged multiparameters' do
      multiparameter_hash = {
        'composite(1)'  => 'a string',
        'composite(2)'  => '1.5',
        'composite(3i)' => '1.5',
        'composite(4f)' => '1.5',
        'composite(5)'  => '',
        'composite(6i)' => '',
        'composite(7f)' => '',
      }
      attributes = { 'composite' => Object.new }

      ::Rails::DataMapper::Models::Composite.
        should_receive(:new).
        with('a string', '1.5', '1.5'.to_i, '1.5'.to_f).
        and_return(attributes['composite'])

      composite_property = mock(::DataMapper::Property)
      composite_property.stub!(:primitive).and_return(::Rails::DataMapper::Models::Composite)

      resource = ::Rails::DataMapper::Models::Fake.new
      resource.stub!(:properties).and_return('composite' => composite_property)

      resource.should_receive(:_super_attributes=).with(attributes)

      resource.attributes = multiparameter_hash
    end

    it 'raises exception on failure' do
      multiparameter_hash = { 'composite(1)'  => 'a string' }
      attributes = { 'composite' => Object.new }

      composite_exception = StandardError.new('foo')
      ::Rails::DataMapper::Models::Composite.
        should_receive(:new).with('a string').and_raise(composite_exception)

      composite_property = mock(::DataMapper::Property)
      composite_property.stub!(:primitive).and_return(::Rails::DataMapper::Models::Composite)

      resource = ::Rails::DataMapper::Models::Fake.new
      resource.stub!(:properties).and_return('composite' => composite_property)

      lambda { resource.attributes = multiparameter_hash }.
        should raise_error(::Rails::DataMapper::MultiparameterAssignmentErrors) { |ex|
          ex.errors.size.should == 1

          error = ex.errors[0]
          error.attribute.should == 'composite'
          error.values.should == ['a string']
          error.exception.should == composite_exception
        }
    end
  end

  describe 'new' do
    it "merges multiparameters" do
      attributes = {
        'updated_at(1i)' => '2004', 'updated_at(2i)' => '6', 'updated_at(3i)' => '24',
        'updated_at(4i)' => '16', 'updated_at(5i)' => '24', 'updated_at(6i)' => '00' }

      topic = ::Rails::DataMapper::Models::Topic.new(attributes)
      topic.updated_at.should == DateTime.new(2004, 6, 24, 16, 24, 0)
    end
  end

  describe 'create' do
    it "merges multiparameters" do
      attributes = {
        'updated_at(1i)' => '2004', 'updated_at(2i)' => '6', 'updated_at(3i)' => '24',
        'updated_at(4i)' => '16', 'updated_at(5i)' => '24', 'updated_at(6i)' => '00' }

      topic = ::Rails::DataMapper::Models::Topic.create(attributes)
      topic.updated_at.should == DateTime.new(2004, 6, 24, 16, 24, 0)
    end
  end
end
