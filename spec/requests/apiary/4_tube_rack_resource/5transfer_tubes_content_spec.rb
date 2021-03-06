require "requests/apiary/4_tube_rack_resource/spec_helper"
describe "5transfer_tubes_content", :tube_rack => true do
  include_context "use core context service"
  it "5transfer_tubes_content" do
  # **Transfer tubes content from a source tube rack to a target tube rack according to a transfer map.**
  # As it is a content transfer between tubes in tube racks, targeted locations mentioned in the transfer map
  # need to contain tubes.
  # 
  # * `source_uuid` uuid of the source tube rack
  # * `target_uuid` uuid of the target tube rack
  # * `transfer_map` map locations in the source tube rack to other locations in the target tube rack
  # 
  # In the example below, the content of the tube in B5 in the tube rack `11111111-2222-3333-4444-555555555555` is
  # tranfered into the tube in C3 in the tube rack `11111111-2222-3333-4444-666666666666`.
    sample1 = Lims::LaboratoryApp::Laboratory::Sample.new(:name => 'sample 1')
    source_tube1 = Lims::LaboratoryApp::Laboratory::Tube.new << Lims::LaboratoryApp::Laboratory::Aliquot.new(:quantity => 10, :type => "sample", :sample => sample1)
    target_tube1 = Lims::LaboratoryApp::Laboratory::Tube.new
    source_tube_rack = Lims::LaboratoryApp::Laboratory::TubeRack.new(:number_of_columns => 12, :number_of_rows => 8)
    target_tube_rack = Lims::LaboratoryApp::Laboratory::TubeRack.new(:number_of_columns => 12, :number_of_rows => 8)
    source_tube_rack["B5"] = source_tube1
    target_tube_rack["C3"] = target_tube1
    
    save_with_uuid sample1 => [1,2,3,4,0], source_tube1 => [1,2,3,4,7], target_tube1 => [1,2,3,4,8], source_tube_rack => [1,2,3,4,5], target_tube_rack => [1,2,3,4,6]

    header('Content-Type', 'application/json')
    header('Accept', 'application/json')

    response = post "/actions/tube_rack_transfer", <<-EOD
    {
    "tube_rack_transfer": {
        "source_uuid": "11111111-2222-3333-4444-555555555555",
        "target_uuid": "11111111-2222-3333-4444-666666666666",
        "transfer_map": {
            "B5": "C3"
        }
    }
}
    EOD
    response.should match_json_response(200, <<-EOD) 
    {
    "tube_rack_transfer": {
        "actions": {
        },
        "user": "user@example.com",
        "application": "application_id",
        "result": {
            "tube_rack": {
                "actions": {
                    "read": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "update": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "delete": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "create": "http://example.org/11111111-2222-3333-4444-666666666666"
                },
                "uuid": "11111111-2222-3333-4444-666666666666",
                "number_of_rows": 8,
                "number_of_columns": 12,
                "location": null,
                "tubes": {
                    "C3": {
                        "actions": {
                            "read": "http://example.org/11111111-2222-3333-4444-888888888888",
                            "create": "http://example.org/11111111-2222-3333-4444-888888888888",
                            "update": "http://example.org/11111111-2222-3333-4444-888888888888",
                            "delete": "http://example.org/11111111-2222-3333-4444-888888888888"
                        },
                        "uuid": "11111111-2222-3333-4444-888888888888",
                        "location": null,
                        "type": null,
                        "max_volume": null,
                        "aliquots": [
                            {
                                "sample": {
                                    "actions": {
                                        "read": "http://example.org/11111111-2222-3333-4444-000000000000",
                                        "update": "http://example.org/11111111-2222-3333-4444-000000000000",
                                        "delete": "http://example.org/11111111-2222-3333-4444-000000000000",
                                        "create": "http://example.org/11111111-2222-3333-4444-000000000000"
                                    },
                                    "uuid": "11111111-2222-3333-4444-000000000000",
                                    "name": "sample 1"
                                },
                                "quantity": 10,
                                "type": "sample",
                                "unit": "mole"
                            }
                        ]
                    }
                }
            }
        },
        "source": {
            "tube_rack": {
                "actions": {
                    "read": "http://example.org/11111111-2222-3333-4444-555555555555",
                    "update": "http://example.org/11111111-2222-3333-4444-555555555555",
                    "delete": "http://example.org/11111111-2222-3333-4444-555555555555",
                    "create": "http://example.org/11111111-2222-3333-4444-555555555555"
                },
                "uuid": "11111111-2222-3333-4444-555555555555",
                "number_of_rows": 8,
                "number_of_columns": 12,
                "location": null,
                "tubes": {
                    "B5": {
                        "actions": {
                            "read": "http://example.org/11111111-2222-3333-4444-777777777777",
                            "create": "http://example.org/11111111-2222-3333-4444-777777777777",
                            "update": "http://example.org/11111111-2222-3333-4444-777777777777",
                            "delete": "http://example.org/11111111-2222-3333-4444-777777777777"
                        },
                        "uuid": "11111111-2222-3333-4444-777777777777",
                        "location": null,
                        "type": null,
                        "max_volume": null,
                        "aliquots": [
                            {
                                "sample": {
                                    "actions": {
                                        "read": "http://example.org/11111111-2222-3333-4444-000000000000",
                                        "update": "http://example.org/11111111-2222-3333-4444-000000000000",
                                        "delete": "http://example.org/11111111-2222-3333-4444-000000000000",
                                        "create": "http://example.org/11111111-2222-3333-4444-000000000000"
                                    },
                                    "uuid": "11111111-2222-3333-4444-000000000000",
                                    "name": "sample 1"
                                },
                                "quantity": 0,
                                "type": "sample",
                                "unit": "mole"
                            }
                        ]
                    }
                }
            }
        },
        "target": {
            "tube_rack": {
                "actions": {
                    "read": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "update": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "delete": "http://example.org/11111111-2222-3333-4444-666666666666",
                    "create": "http://example.org/11111111-2222-3333-4444-666666666666"
                },
                "uuid": "11111111-2222-3333-4444-666666666666",
                "number_of_rows": 8,
                "number_of_columns": 12,
                "location": null,
                "tubes": {
                    "C3": {
                        "actions": {
                            "read": "http://example.org/11111111-2222-3333-4444-888888888888",
                            "create": "http://example.org/11111111-2222-3333-4444-888888888888",
                            "update": "http://example.org/11111111-2222-3333-4444-888888888888",
                            "delete": "http://example.org/11111111-2222-3333-4444-888888888888"
                        },
                        "uuid": "11111111-2222-3333-4444-888888888888",
                        "location": null,
                        "type": null,
                        "max_volume": null,
                        "aliquots": [
                            {
                                "sample": {
                                    "actions": {
                                        "read": "http://example.org/11111111-2222-3333-4444-000000000000",
                                        "update": "http://example.org/11111111-2222-3333-4444-000000000000",
                                        "delete": "http://example.org/11111111-2222-3333-4444-000000000000",
                                        "create": "http://example.org/11111111-2222-3333-4444-000000000000"
                                    },
                                    "uuid": "11111111-2222-3333-4444-000000000000",
                                    "name": "sample 1"
                                },
                                "quantity": 10,
                                "type": "sample",
                                "unit": "mole"
                            }
                        ]
                    }
                }
            }
        },
        "transfer_map": {
            "B5": "C3"
        }
    }
}
    EOD

  end
end
