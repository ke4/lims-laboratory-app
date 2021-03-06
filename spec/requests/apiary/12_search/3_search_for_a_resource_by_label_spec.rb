require "requests/apiary/12_search/spec_helper"
describe "search_for_a_resource_by_label", :search => true do
  include_context "use core context service"
  it "search_for_a_resource_by_label" do
  # **Search for a resource by label**
  # 
  # * `description` describe the search
  # * `model` searched model
  # * `criteria` set parameters for the search. Here, it can be a combination of the following attributes:
  #     * `position`
  #     * `type`
  #     * `value`
  # 
  # The search below looks for a tube by its label which is a `sanger-barcode` with the position 
  # `front barcode` and the value `ABC123456`.
  # 
  # To actually get the search results, you need to access the first page of result 
  # thanks to the `first` action in the JSON response.

    header('Content-Type', 'application/json')
    header('Accept', 'application/json')

    response = post "/searches", <<-EOD
    {
    "search": {
        "description": "search for a tube by label",
        "model": "tube",
        "criteria": {
            "label": {
                "position": "front barcode",
                "type": "sanger-barcode",
                "value": "ABC123456"
            }
        }
    }
}
    EOD
    response.should match_json_response(200, <<-EOD) 
    {
    "search": {
        "actions": {
            "read": "http://example.org/11111111-2222-3333-4444-555555555555",
            "first": "http://example.org/11111111-2222-3333-4444-555555555555/page=1",
            "last": "http://example.org/11111111-2222-3333-4444-555555555555/page=-1"
        },
        "uuid": "11111111-2222-3333-4444-555555555555"
    }
}
    EOD

  end
end
