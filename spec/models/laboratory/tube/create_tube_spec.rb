# Spec requirements
require 'models/actions/spec_helper'
require 'models/actions/action_examples'
require 'models/laboratory/location_shared'

#Model requirements
require 'models/laboratory/spec_helper'
require 'models/laboratory/resource_with_labellable_shared'
require 'models/laboratory/resource_with_location_shared'
require 'lims-laboratory-app/laboratory/tube/create_tube'
require 'models/laboratory/tube_shared'
require 'lims-core/persistence/store'

module Lims::LaboratoryApp
  module Laboratory
    describe Tube::CreateTube, :tube => true, :laboratory => true, :persistence => true do
      context "with a valid store" do
        include_context "create object"
        include_context "define location"
        let (:store) { Lims::Core::Persistence::Store.new }
        let(:user) { double(:user) }
        let(:application) { "Test create tube" }
        let(:tube_type) { "Eppendorf" }
        let(:tube_max_volume) { 2 }

        context "create an empty tube" do
          subject do
            Tube::CreateTube.new(:store => store, :user => user, :application => application)  do |a,s|
              a.type = tube_type
              a.max_volume = tube_max_volume
            end
          end 
          it_behaves_like "an action"

          it "create a tube when called" do
            Lims::Core::Persistence::Session.any_instance.should_receive(:save_all)
            result = subject.call
            result.should be_a(Hash)
            result[:tube].should be_a(Laboratory::Tube)
            result[:tube].type.should == tube_type
            result[:tube].max_volume.should == tube_max_volume
            result[:uuid].should == uuid
          end
        end

        context "create a tube with a location" do
          subject do
            Tube::CreateTube.new(:store => store, :user => user, :application => application) do |a,s|
              a.location = location
            end
          end
          it_behaves_like "creating a resource with a location", Laboratory::Tube
        end

        context "create a tube with labellable" do
          subject do
            Tube::CreateTube.new(:store => store, :user => user, :application => application) do |a,s|
              a.labels = labels
            end
          end
          it_behaves_like "creating a resource with a labellable", Laboratory::Tube
        end

        context "create a tube with samples" do
          let(:sample) { new_sample(1) }
          subject do 
            Tube::CreateTube.new(:store => store, :user => user, :application => application) do |a,s|
              a.aliquots = [{:sample => sample }] 
              a.type = tube_type
              a.max_volume = tube_max_volume
            end
          end
          it_behaves_like "an action"
          it "create a tube when called" do
            Lims::Core::Persistence::Session.any_instance.should_receive(:save_all)
            result = subject.call
            result.should be_a(Hash)
            result[:tube].should be_a(Laboratory::Tube)
            result[:uuid].should == uuid
            result[:tube].type.should == tube_type
            result[:tube].max_volume.should == tube_max_volume
            result[:tube].first.sample.should == sample
          end
        end

        context "create a tube with samples and a location" do
          let(:sample) { new_sample(1) }
          subject do
            Tube::CreateTube.new(:store => store, :user => user, :application => application) do |a,s|
              a.aliquots = [{:sample => sample }]
              a.type = tube_type
              a.max_volume = tube_max_volume
              a.location = location
            end
          end
          it_behaves_like "an action"
          it "create a tube when called" do
            Lims::Core::Persistence::Session.any_instance.should_receive(:save_all)
            result = subject.call
            result.should be_a(Hash)
            result[:tube].should be_a(Laboratory::Tube)
            result[:uuid].should == uuid
            result[:tube].type.should == tube_type
            result[:tube].max_volume.should == tube_max_volume
            result[:tube].first.sample.should == sample
            result[:tube].location.should == location
          end
        end

      end
    end
  end
end
