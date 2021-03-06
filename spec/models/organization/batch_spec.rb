# Spec requirements
require 'models/spec_helper'

# Model requirements
require 'lims-laboratory-app/organization/batch'

module Lims::LaboratoryApp::Organization
  describe Batch, :batch => true, :organization => true do
    def self.it_has_a(attribute, type=nil)
      it "responds to #{attribute}" do
        subject.should respond_to(attribute)
      end

      if type
        it "'s #{attribute} is a #{type}" do
          subject.send(attribute).andtap { |v| v.should be_a(type) }
        end
      end
    end

    def self.it_can_assign(attribute)
      it "can assign #{attribute}" do
        value = double(:attribute)
        subject.send("#{attribute}=", value)
        subject.send(attribute).should == value
      end
    end

    it_can_assign :process
    it_has_a :process
    it_can_assign :kit
    it_has_a :kit

    it "sets a process" do
      process = double(:process)
      subject.process = process
      subject.process.should == process
    end

    it "sets a kit" do
      kit = double(:kit)
      subject.kit = kit
      subject.kit.should == kit
    end
  end
end
