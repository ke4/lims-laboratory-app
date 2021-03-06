# Spec requirements
require 'models/laboratory/spec_helper'

# Model requirements
require 'lims-laboratory-app/laboratory/oligo'

module Lims::LaboratoryApp::Laboratory
  describe Oligo, :oligo => true, :laboratory => true do
    let(:sequence_1) { "AAA" }
    let(:sequence_2) { "CCCT" }
    context "to be valid" do
      pending "validation not implemented yet" do
        it "requires a sequence" do
          Oligo.new(:sequence => "")
          Oligo.valid?.should == false
        end

        it "require a valid sequence" do
          Oligo.new("ABC")
          Oligo.valid?.should == false
        end
      end
    end
    context "#string behavior" do
      subject { Oligo.new(sequence_1) }

      it "should be displayed its sequence" do
        subject.to_s.should == sequence_1.to_s
        STDOUT.should_receive(:write).with(sequence_1)
        print subject.to_s

      end

      it "should be compared to its sequence" do
        subject.should == sequence_1
      end

      its(:size) { should == sequence_1.size }
    end

    it "should compare sequences" do
      Oligo.new(sequence_1).should == Oligo.new(sequence_1)
      Oligo.new(sequence_1).should_not == Oligo.new(sequence_2)
    end
  end
end

