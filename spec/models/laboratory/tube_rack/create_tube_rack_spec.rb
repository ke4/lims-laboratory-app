# Spec requirements
require 'models/actions/action_examples'
require 'models/actions/spec_helper'
require 'models/laboratory/location_shared'

# Model requirements
require 'lims-laboratory-app/laboratory/tube_rack/create_tube_rack'
require 'lims-laboratory-app/laboratory/tube/tube_persistor'

module Lims::LaboratoryApp
  module Laboratory

    shared_context "has tube rack dimension" do |row, col|
      let(:number_of_rows) { row }
      let(:number_of_columns) { col }
      let(:dimensions) {{:number_of_rows => row, :number_of_columns => col}}
    end

    shared_context "for empty tube rack" do
      subject do
        TubeRack::CreateTubeRack.new(:store => store, :user => user, :application => application) do |a,s|
          a.ostruct_update(dimensions)
          a.location = location
        end
      end

      let(:tube_rack_checker) do
        lambda do |tube_rack|
          tube_rack.each { |position| position.should be_nil }
        end
      end
    end

    shared_context "for a tube rack with tubes" do
      let(:tubes) {{
        "A1" => Laboratory::Tube.new,
        "B3" => Laboratory::Tube.new,
        "D5" => Laboratory::Tube.new,
        "F10" => Laboratory::Tube.new
      }} 

      subject do
        TubeRack::CreateTubeRack.new(:store => store, :user => user, :application => application) do |a,s|
          a.ostruct_update(dimensions)
          a.tubes = tubes
          a.location = location
        end
      end

      let(:tube_rack_checker) do
        lambda do |tube_rack|
          tubes.each do |position, tube|
            tube_rack[position].should == tube
          end
        end
      end
    end

    shared_examples_for "creating a tube rack" do
      include_context "create object"
      it_behaves_like "an action"

      before do
        Tube::TubePersistor.any_instance.stub(:belongs_to_tube_rack?).and_return(false)
      end

      it "creates a tube rack when called" do
        result = subject.call
        result.should be_a Hash

        tube_rack = result[:tube_rack]
        tube_rack.number_of_rows.should == dimensions[:number_of_rows]
        tube_rack.number_of_columns.should == dimensions[:number_of_columns]
        tube_rack.location.should == location
        tube_rack_checker[tube_rack]

        result[:uuid].should == uuid
      end
    end

    describe TubeRack::CreateTubeRack, :tube_rack => true, :laboratory => true, :persistence => true do
      context "valid calling context" do
        let!(:store) { Lims::Core::Persistence::Store.new() }
        include_context "for application", "Test TubeRack creation"
        include_context "has tube rack dimension", 8, 12 
        include_context "define location"

        context do
          include_context "for empty tube rack"
          it_behaves_like "creating a tube rack"
        end

        context do
          include_context "for a tube rack with tubes"
          it_behaves_like "creating a tube rack"
        end
      end
    end
  end
end
