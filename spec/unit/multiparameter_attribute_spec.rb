require 'spec_helper'
require "dm-rails/multiparameter_attribute_support"

describe "Multiparameter attributes (ie dates) in rails forms" do

  supported_by :all do
    before(:all) do
      class MuliparameterRecource
        include DataMapper::Resource

        property :id, Serial
        property :name, String
        property :birthday, Date
      end
      MuliparameterRecource.auto_migrate!
    end

    it "should not blow up" do
      lambda { create_mpr }.should_not raise_error
    end

    it "should assign multiparameter property correctly" do
      mpr = create_mpr
      mpr.birthday.should == Date.new(1989,3,26)
    end

    it "should still assign the regular values" do
      mpr = create_mpr
      mpr.name.should == "joe"
    end

    it "should not change the attributes hash" do
      mpr = create_mpr
      mpr.attributes.should == {:birthday => Date.new(1989,3,26), :name => "joe", :id => mpr.id}
    end

    it "should not change non-multiparameter attributes" do
      mpr = MuliparameterRecource.new
      attributes = { "birthday" => Date.new(1989,3,26), "name" => "joe" }
      mpr.should_receive(:attributes_without_multiparameter=).with(attributes.dup) # dup to make sure original hash isn't modified
      mpr.send(:attributes_with_multiparameter=, multiparameter_hash).should == attributes
    end
  end

  def multiparameter_hash
    {
     "birthday(2i)"=>"3",
     "birthday(3i)"=>"26",
     "birthday(1i)"=>"1989",
     "name" => "joe"
     }
  end

  def create_mpr
    MuliparameterRecource.create(multiparameter_hash)
  end

end

