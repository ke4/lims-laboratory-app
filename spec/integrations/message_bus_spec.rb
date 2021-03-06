require 'rubygems'
require 'bunny'
require 'lims-core'
require 'integrations/spec_helper'
require 'timecop'

def order_expected_payload(args)
  action_url = "http://example.org/#{args[:uuid]}"
  user_url = "http://example.org/#{args[:user_uuid]}"
  study_url = "http://example.org/#{args[:study_uuid]}"

  {:order => {
    :actions => {:read => action_url, :create => action_url, :update => action_url, :delete => action_url},
    :uuid => args[:uuid], 
   :pipeline => args[:pipeline],
    :status => args[:status],
    :parameters => args[:parameters],
    :state => args[:state],
    :cost_code => args[:cost_code],
    :creator => {
      :actions => {:read => user_url, :create => user_url, :update => user_url, :delete => user_url},
      :uuid => args[:user_uuid] ,
      :email => args[:user_email]
    },
    :study => {
      :actions => {:read => study_url, :create => study_url, :update => study_url, :delete => study_url},
      :uuid => args[:study_uuid] 
    },
    :items => args[:items]
  },
  :action => args[:action],
  :date => args[:date],
  :user => args[:user]} 
end


shared_examples_for "messages on the bus" do 
  before(:each) { Timecop.freeze(Time.utc(2013,"jan",1,20,0,0)) }
  after(:each) { Timecop.return }

  it "publishes a message after order creation" do
    message_bus.should_receive(:publish) do |create_payload, create_setting| 
      create_payload.should == expected_create_payload
     create_settings.should ==  expected_create_settings
    end 
    post(create_url, parameters.to_json)
  end

  it "publishes messages after order creation and update" do
    message_bus.should_receive(:publish) do |create_payload, create_setting| 
      create_payload.should == expected_create_payload
     create_settings.should ==  expected_create_settings
    end 
    message_bus.should_receive(:publish).with(expected_update_payload, expected_update_settings) 
    post(create_url, parameters.to_json)
    put(update_url, update_parameters.to_json)
  end
end


describe "Message Bus" do
  def self.user_email 
    'creator@example.com'
  end
  let(:user_email) { self.class.user_email }
  include_context "use core context service", user_email
  include_context "JSON"
  include_context "use generated uuid"

  let(:study_uuid) { "55555555-2222-3333-6666-777777777777".tap do |uuid|
    store.with_session do |session|
      study = Lims::LaboratoryApp::Organization::Study.new
      set_uuid(session, study, uuid)
    end
  end
  } 

  let!(:user_uuid) { "66666666-2222-4444-9999-000000000000".tap do |uuid|
    store.with_session do |session|
      user = Lims::LaboratoryApp::Organization::User.new(:email => user_email)
      set_uuid(session, user, uuid)
    end
  end
  }
  let(:create_url) { "/orders" }
  let(:update_url) { "/#{uuid}" }     
  let(:create_action) { "create" }
  let(:update_action) { "update_order" }
  let(:order_items) { {
    :source_role1 => [{ "uuid" => "99999999-2222-4444-9999-000000000000", "status" => "done", "batch" => nil}],
    :target_role1 => [{ "uuid" => "99999999-2222-4444-9999-111111111111", "status" => "pending", "batch" => nil}] } 
  }
  let(:order_parameters) { {} }
  let(:order_state) { {} }
  let(:order_status) { "draft" }
  let(:order_cost_code) { "cost code" }
  let(:order_pipeline) { "pipeline" }
  let(:parameters) { {:order => {:user_uuid => user_uuid,
                                 :study_uuid => study_uuid,
                                 :sources => {:source_role1 => ["99999999-2222-4444-9999-000000000000"]},
                                 :targets => {:target_role1 => ["99999999-2222-4444-9999-111111111111"]},
                                 :cost_code => order_cost_code,
                                 :pipeline => order_pipeline}} }
  let(:update_parameters) { {:event => :build} }
  let(:payload_parameters) {{
    :uuid => uuid,
    :user_email => user_email,
    :study_uuid => study_uuid,
    :user_uuid => user_uuid,
    :pipeline => order_pipeline,
    :status => order_status,
    :parameters => order_parameters,
    :state => order_state,
    :cost_code => order_cost_code,
    :items => order_items
  }}

  context "on valid order creation and update" do
    let(:date) { "2013-01-01 20:00:00 UTC" }
    let(:user) { "user" }
    let(:expected_create_settings) { {:routing_key => "applicationid.creatorexamplecom.order.create" } }
    let(:expected_update_settings) { {:routing_key => "applicationid.creatorexamplecom.order.updateorder" } }
    let(:expected_create_payload) { order_expected_payload(payload_parameters.merge({
      :action => create_action,
      :date => date,
      :user => user_email
    })).to_json }
    let(:expected_update_payload) { order_expected_payload(payload_parameters.merge({
      :action => update_action, 
      :status => "pending",
      :date => date,
      :user => user_email
    })).to_json }
    it_behaves_like "messages on the bus"
  end
end
