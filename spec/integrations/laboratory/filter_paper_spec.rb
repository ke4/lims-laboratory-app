#spin_column_spec.rb
require 'integrations/laboratory/spec_helper'

require 'lims-api/context_service'
require 'integrations/laboratory/resource_shared'
require 'lims-core/persistence/sequel'

require 'integrations/laboratory/lab_resource_shared'
require 'integrations/laboratory/tube_resource_shared'
require 'integrations/laboratory/plate_resource_shared'

shared_context "expect filter paper JSON" do
  let(:expected_json) {
    path = "http://example.org/#{uuid}"
    { "filter_paper" => {"actions" => {"read" => path,
                                      "update" => path,
                                      "delete" => path,
                                      "create" => path},
                        "uuid" => uuid,
                        "location" => location,
                        "aliquots" => aliquot_array}
    }
  }
end

shared_context "expect filter paper JSON with labels" do
  let(:expected_json) {
    path = "http://example.org/#{uuid}"
    { "filter_paper" => {"actions" => {"read" => path,
                                      "update" => path,
                                      "delete" => path,
                                      "create" => path},
                        "uuid" => uuid,
                        "location" => location,
                        "aliquots" => aliquot_array,
                        "labels" => actions_hash.merge(labellable_uuid_hash).merge(labels_hash)}
    }
  }
end

describe Lims::LaboratoryApp::Laboratory::FilterPaper do
  include_context "use core context service"
  include_context "JSON"
  include_context "use generated uuid"
  let(:asset) { "filter_paper" }
  let(:model) { "filter_papers" }
  let(:location) { nil }

  context "#create" do
    context do
      include_context "for empty tube-like asset"
      include_context "expect filter paper JSON"
      it_behaves_like('creating a resource') 
    end
    context do
      include_context "for tube-like asset with samples"
      include_context "expect filter paper JSON"
      include_context "with filled aliquots"
      it_behaves_like('creating a resource')
    end

    context do
      include_context "for tube-like asset with samples and labels"
      include_context "resource with labels for the expected JSON"
      include_context "with labels"
      include_context "expect filter paper JSON with labels"
      include_context "with filled aliquots"
      it_behaves_like('creating a resource with a label on it')
    end
  end

  context "#transfer multiple filter papers to wells" do
    let(:url) { "/actions/transfer_multiple_filter_papers_to_wells" }
    context "with empty filter papers" do
      let(:parameters) { { :transfer_multiple_filter_papers_to_wells => {} } }
      let(:expected_json) { {"errors" => {
        "transfers"=> [
          "Transfers must not be blank"
        ]}
      }}
      it_behaves_like "an invalid core action", 422  # Unprocessable entity
    end

    context "from filter paper" do
      let(:unit_type) { "mole" }
      let(:aliquot_type) { "NA" }
      let(:quantity) { 100 }
      let!(:aliquot_quantity) { 100 }
      let(:volume) { 100 }
      let(:sample_uuid) { '11111111-2222-3333-4444-555555555555' }
      let(:sample_name) { "sample 1" }

      context "to well" do
        let(:asset_to_create) { Lims::LaboratoryApp::Laboratory::FilterPaper }
        include_context "aliquots with solvent"
        include_context "for creating a tube-like asset with aliquot and solvent in it"
        include_context "for creating a plate-like with aliquots and solvent in it"
        let(:target_plate_uuid) { new_empty_plate('11111111-2222-3333-1111-000000000001') }
        let(:plate_type) { nil }
        let(:number_of_rows) { 8 }
        let(:number_of_columns) { 12 }
        let(:transfers) { [ { "source_uuid" => source_tube_like1_uuid,
                              "target_uuid" => target_plate_uuid,
                              "target_location" => "B2"}
          ]
        }
        let(:parameters) { { :transfer_multiple_filter_papers_to_wells => { :transfers => transfers} }}
        let(:solvent) { {"type" => "solvent", "unit" => "ul"} }
        let(:target_aliquot_array) {
          path = "http://example.org/#{sample_uuid}"
          [ { "sample"=> {"actions" => { "read" => path,
                                         "update" => path,
                                         "delete" => path,
                                         "create" => path },
                                         "uuid" => sample_uuid,
                                         "name" => sample_name},
                                         "type" => aliquot_type,
                                         "unit" => unit_type},
            solvent
          ]
        }

        let(:target_wells) { {
          "A1"=>[],"A2"=>[],"A3"=>[],"A4"=>[],"A5"=>[],"A6"=>[],"A7"=>[],"A8"=>[],"A9"=>[],"A10"=>[],"A11"=>[],"A12"=>[],
          "B1"=>[],"B2"=>target_aliquot_array,"B3"=>[],"B4"=>[],"B5"=>[],"B6"=>[],"B7"=>[],"B8"=>[],"B9"=>[],"B10"=>[],"B11"=>[],"B12"=>[],
          "C1"=>[],"C2"=>[],"C3"=>[],"C4"=>[],"C5"=>[],"C6"=>[],"C7"=>[],"C8"=>[],"C9"=>[],"C10"=>[],"C11"=>[],"C12"=>[],
          "D1"=>[],"D2"=>[],"D3"=>[],"D4"=>[],"D5"=>[],"D6"=>[],"D7"=>[],"D8"=>[],"D9"=>[],"D10"=>[],"D11"=>[],"D12"=>[],
          "E1"=>[],"E2"=>[],"E3"=>[],"E4"=>[],"E5"=>[],"E6"=>[],"E7"=>[],"E8"=>[],"E9"=>[],"E10"=>[],"E11"=>[],"E12"=>[],
          "F1"=>[],"F2"=>[],"F3"=>[],"F4"=>[],"F5"=>[],"F6"=>[],"F7"=>[],"F8"=>[],"F9"=>[],"F10"=>[],"F11"=>[],"F12"=>[],
          "G1"=>[],"G2"=>[],"G3"=>[],"G4"=>[],"G5"=>[],"G6"=>[],"G7"=>[],"G8"=>[],"G9"=>[],"G10"=>[],"G11"=>[],"G12"=>[],
          "H1"=>[],"H2"=>[],"H3"=>[],"H4"=>[],"H5"=>[],"H6"=>[],"H7"=>[],"H8"=>[],"H9"=>[],"H10"=>[],"H11"=>[],"H12"=>[]}}
        let(:expected_json) {
          source_tube_like1_url = "http://example.org/#{source_tube_like1_uuid}"
          target_plate_url = "http://example.org/#{target_plate_uuid}"
          { :transfer_multiple_filter_papers_to_wells =>
            { :actions => {},
              :user => "user@example.com",
              :application => "application_id",
              :result => {
                :sources => [
                  {"filter_paper" => {
                      "actions" => {
                        "read" => source_tube_like1_url,
                        "create" => source_tube_like1_url,
                        "update" => source_tube_like1_url,
                        "delete" => source_tube_like1_url
                      },
                      "uuid" => source_tube_like1_uuid,
                      "location" => location,
                      "aliquots" => fp_aliquot_array_source
                    }}
                ],
                :targets => [
                  { "plate" => { "actions" => {"read" => target_plate_url,
                    "create" => target_plate_url,
                    "update" => target_plate_url,
                    "delete" => target_plate_url} ,
                    "uuid" => target_plate_uuid,
                    "type" => plate_type,
                    "number_of_rows" => number_of_rows,
                    "number_of_columns" => number_of_columns,
                    "location" => location,
                    "wells"=> target_wells}}
                ]
              },
              :transfers => transfers
            }
          }
        }

        it_behaves_like "a valid core action"
      end
    end
  end
end
