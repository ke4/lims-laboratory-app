# Spec requirements
require 'models/laboratory/spec_helper'

# Model requirements
require 'lims-laboratory-app/laboratory/aliquot'

module Lims::LaboratoryApp::Laboratory
  describe Aliquot, :aliquot => true, :laboratory => true do
    context "to be valid" do
      let (:aliquot) {Aliquot.new(:quantity=>10)}

      xit "must have everything needed" do
        aliquot.valid?.should be_true
      end
      it "must have an owner"
      xit "must have a type" do
        # this is an example to mostly test yard-rspec.
        aliquot.type=nil
        aliquot.valid?.should be_false
      end
      it "must have a quantity" do
      pending "we might use nil quanity for unknown quantity" do
        aliquot.quantity=nil
        aliquot.valid?.should eq false
      end
      end

      xit "must have a positive quantity" do
        aliquot.quantity=-5
        aliquot.valid?.should  be_false
      end

      it "should be in a receptacle"
      it "can't be empty"
    end

    context "a solvent" do
      subject{ described_class.new(:type => Aliquot::Solvent) }
      its(:dimension) { should == Aliquot::Volume }
      its(:unit) { should == "ul" }

      context "with a quantity" do
        subject{ described_class.new(:type => Aliquot::Solvent, :quantity => 1000) }
        it "can have a quantity added to it " do
          subject.increase_quantity(50).should == 1050
        end
        it "can have an unknown quantity added to it " do
          subject.increase_quantity(nil).should == 1000
        end
      end

    end
      context "without a quantity" do
        it "can have a quantity added to it " do
          subject.increase_quantity(50).should == 50
        end
        it "can have an unknown quantity added to it " do
          subject.increase_quantity(nil).should == nil
        end
      end

    context "#add_quantity" do
      it do
        Aliquot::add_quantity(nil,nil).should == nil
        Aliquot::add_quantity(nil,2).should == 2
        Aliquot::add_quantity(1,2).should == 3
      end
    end
  end
end
