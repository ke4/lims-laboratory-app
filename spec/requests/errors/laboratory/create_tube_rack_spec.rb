require "requests/errors/laboratory/spec_helper"
describe "create_tube_rack" do
  include_context "use core context service"
  it "Create tube rack with non orphan tube" do
  # Tube is already contained in another tube rack
    tube = Lims::LaboratoryApp::Laboratory::Tube.new
    tube_rack = Lims::LaboratoryApp::Laboratory::TubeRack.new(:number_of_rows => 8, :number_of_columns => 12)
    tube_rack["A1"] = tube
    
    save_with_uuid tube => [1,2,3,4,0], tube_rack => [1,2,3,4,1]

    header('Content-Type', 'application/json')
    header('Accept', 'application/json')

    response = post "/tube_racks", <<-EOD
    {
    "tube_rack": {
        "number_of_rows": 8,
        "number_of_columns": 12,
        "tubes": {
            "B1": "11111111-2222-3333-4444-000000000000"
        }
    }
}
    EOD
    response.should match_json_response(500, <<-EOD) 
    {
    "general": [
        "The tube in B1 belongs to another tube rack."
    ]
}
    EOD

  end
end
