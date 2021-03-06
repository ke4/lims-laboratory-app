require "requests/apiary/3_tube_resource/spec_helper"
describe "list_actions_for_a_tube_resource", :tube => true do
  include_context "use core context service"
  it "list_actions_for_a_tube_resource" do
  # **List actions for a tube resource.**
  # 
  # * `create` creates a new tube via HTTP POST request
  # * `read` currently returns the list of actions for a tube resource via HTTP GET request
  # * `first` lists the first tube resources in a page browsing system
  # * `last` lists the last tube resources in a page browsing system

    header('Content-Type', 'application/json')
    header('Accept', 'application/json')

    response = get "/tubes"
    response.should match_json_response(200, <<-EOD) 
    {
    "tubes": {
        "actions": {
            "create": "http://example.org/tubes",
            "read": "http://example.org/tubes",
            "first": "http://example.org/tubes/page=1",
            "last": "http://example.org/tubes/page=-1"
        }
    }
}
    EOD

  end
end
