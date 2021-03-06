# Spec requirements
require 'models/actions/spec_helper'
require 'models/actions/action_examples'
require 'models/laboratory/location_shared'

require 'models/laboratory/container_like_asset_shared'

#Model requirements
require 'lims-laboratory-app/laboratory/plate/all'

module Lims::LaboratoryApp
  module Laboratory
    shared_context "for empty plate" do
      subject do
        Plate::CreatePlate.new(:store => store, :user => user, :application => application)  do |a,s|
          a.ostruct_update(dimensions)
          a.type = plate_type
          a.location = location
        end
      end

      let (:plate_checker) do
        lambda do |plate|
          plate.each  { |w| w.should be_empty }
        end
      end
    end
    shared_context "for plate with a map of samples" do
      let(:wells_description) do
        {}.tap do |h|
          1.upto(number_of_rows) do |row|
            1.upto(number_of_columns) do |column|
              h[Laboratory::Plate.indexes_to_element_name(row-1, column-1)] = [{
                :sample => new_sample(row, column),
                :quantity => nil,
                :out_of_bounds => {:attribute_1 => "value 1", :attribute_2 => row+column}
              }]
            end
          end
        end
      end
      subject do
        Plate::CreatePlate.new(:store => store, :user => user, :application => application)  do |a,s|
          a.ostruct_update(dimensions)
          a.wells_description = wells_description
          a.type = plate_type
          a.location = location
        end
      end

      let (:plate_checker) do
        lambda do |plate|
          wells_description.each do |well_name, expected_aliquots|
            aliquots = plate[well_name]
            aliquots.size.should == 1
            aliquots.first.sample.should == expected_aliquots.first[:sample]
            aliquots.first.out_of_bounds.should == expected_aliquots.first[:out_of_bounds]
          end
        end
      end
    end

    shared_examples_for "creating a plate" do
      include_context "create object"
      it_behaves_like "an action"
      it "creates a plate when called" do
        result = subject.call()
        result.should be_a Hash

        plate = result[:plate]
        plate.number_of_rows.should == dimensions[:number_of_rows]
        plate.number_of_columns.should == dimensions[:number_of_columns]
        plate.type.should == plate_type
        plate.location.should == location
        plate_checker[plate]

        result[:uuid].should == uuid
      end
    end

    shared_context "has plate dimension" do |row, col|
      let(:number_of_rows) { row }
      let(:number_of_columns) { col }
      let(:dimensions) {{ :number_of_rows => row, :number_of_columns => col }}
    end

    describe Plate::CreatePlate, :plate => true, :laboratory => true, :persistence => true  do
      context "valid calling context" do
        let!(:store) { Lims::Core::Persistence::Store.new() }
        include_context "container-like asset factory"
        include_context "define location"
        include_context("for application",  "Test plate creation")

        include_context("has plate dimension", 8, 12)
        let(:plate_type) { double(:plate_type) }

        context do
          include_context "for empty plate"
          it_behaves_like('creating a plate')
        end
        context do
          include_context "for plate with a map of samples"
          it_behaves_like('creating a plate')
        end
      end
    end
  end
end
