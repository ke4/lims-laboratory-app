# Spec requirements
require 'models/persistence/sequel/spec_helper'

require 'models/laboratory/tube_rack_shared'
require 'models/persistence/resource_shared'
require 'models/persistence/sequel/store_shared'
require 'models/persistence/sequel/page_shared'
require 'models/persistence/filter/multi_criteria_sequel_filter_shared'
require 'models/persistence/filter/label_sequel_filter_shared'
require 'models/laboratory/location_shared'

# Model requirements
require 'lims-laboratory-app/laboratory/tube_rack/all'
require 'lims-laboratory-app/laboratory/tube/all'

require 'lims-laboratory-app/labels/labellable/all'

module Lims::LaboratoryApp

  describe "Sequel#TubeRack ", :tube => true, :laboratory => true, :persistence => true, :sequel => true do
    include_context "sequel store"
    include_context "tube_rack factory"
    include_context "define location"

    include

    def last_tube_rack_id(session)
      session.tube_rack.dataset.order_by(:id).last[:id]
    end

    context "8*12 TubeRack" do
      # Set default dimension to create a tube_rack
      let(:number_of_rows) { 8 }
      let(:number_of_columns) { 12 }
      let(:expected_tube_rack_size) { number_of_rows*number_of_columns }

      context do
        subject { new_tube_rack_with_samples(3) }
        it_behaves_like "storable resource", :tube_rack, {:tube_racks => 1, :tubes =>  8*12, :tube_rack_slots => 8*12, :aliquots => 4*8*12 }
      end

      context "already created tube_rack" do
        let(:tube) { new_empty_tube << aliquot }
        let(:aliquot) { new_aliquot }
        before (:each) do
          store.with_session { |session| session << new_empty_tube_rack().tap {|_| _[0]=  tube } }
        end
        let(:tube_rack_id) { store.with_session { |session| @tube_rack_id = last_tube_rack_id(session) } }

        context "when modified within a session" do
          before do
            store.with_session do |s|
              tube_rack = s.tube_rack[tube_rack_id]
              tube_rack[0].clear
              tube_rack[1]= new_empty_tube
              tube_rack[1]<< aliquot
            end
          end
          it "should be saved" do
            store.with_session do |session|
              f = session.tube_rack[tube_rack_id]
              f[0].should == [] # empty tube
              f[1].should == [aliquot]
              f[7].should be_nil # not tube
            end
          end
        end
        context "when modified outside a session" do
          before do
            tube_rack = store.with_session do |s|
              s.tube_rack[tube_rack_id]
            end
            tube_rack[0].clear
            tube_rack[1]= new_empty_tube
            tube_rack[1]<< aliquot
          end
          it "should not be saved" do
            store.with_session do |session|
              f = session.tube_rack[tube_rack_id]
              f[7].should be_nil
              f[1].should be_nil
              f[0].should == [aliquot]
            end
          end
        end
        context "should be deletable" do
          before {
            # add some aliquot to the tube
            store.with_session do |session|
            tube_rack = session.tube_rack[tube_rack_id]
            1.upto(10) { |i|  3.times { |j| tube_rack[i] = (new_empty_tube <<  new_aliquot(i,j)) } }
            end
          }

          def delete_tube_rack
            store.with_session do |session|
              tube_rack = session.tube_rack[tube_rack_id]
              session.delete(tube_rack)
            end
          end

          it "deletes the tube_rack row" do
            expect { delete_tube_rack }.to change { db[:tube_racks].count}.by(-1)
          end

          it "deletes the tubes rows" do
            expect { delete_tube_rack }.to change { db[:tube_rack_slots].count}.by(-11)
          end
          it "doesn't delete the tubes" do
            expect { delete_tube_rack }.to change { db[:tubes].count}.by(0)
          end
        end

        context "#lookup by label" do
          let!(:uuid) {
            store.with_session do |session|
              tube_rack = session.tube_rack[tube_rack_id]
              session.uuid_for!(tube_rack)
            end
          }

          it_behaves_like "labels filtrable"

        end

        context "with a location", :testt => true do
          it "can be saved and reloaded" do
            tube_rack_id = save(new_tube_rack_with_samples(3))

            store.with_session do |session|
              tube_rack = session.tube_rack[tube_rack_id]
              tube_rack.location.should == location
            end
          end
        end

      end

      context do
        let(:constructor) { lambda { |*_| new_empty_tube_rack } }
        it_behaves_like "paginable resource", :tube_rack
        it_behaves_like "filtrable", :tube_rack
      end
    end
  end
end
