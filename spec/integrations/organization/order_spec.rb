require 'spec_helper'

require 'lims-api/context_service'
require 'integrations/laboratory/resource_shared'
require 'lims-core'
require 'lims-core/persistence/sequel'

require 'integrations/laboratory/lab_resource_shared'
require 'integrations/organization/spec_helper'

module Lims::LaboratoryApp

  shared_context "json order" do
    let(:expected_json) {
          action_url = "http://example.org/#{uuid}"
          user_url = "http://example.org/#{user_uuid}"
          study_url = "http://example.org/#{study_uuid}"

          {:order => {
            :actions => {:read => action_url, :create => action_url, :update => action_url, :delete => action_url},
            :uuid => uuid, 
            :creator => {
              :actions => {:read => user_url, :create => user_url, :update => user_url, :delete => user_url},
              :uuid => user_uuid ,
              :email => user_email
            },
            :pipeline => order_pipeline,
            :status => order_status,
            :parameters => order_parameters,
            :state => order_state,
            :study => {
              :actions => {:create => study_url, :delete => study_url, :read => study_url, :update => study_url},
              :uuid => study_uuid 
            },
            :cost_code => order_cost_code,
            :items => order_items
          }}
    }  
  end

  shared_context "json batch" do
    let(:batch_json) {
      url = "http://example.org/#{batch_uuid}"
      {
        "actions" => {
          "read" => url,
          "create" => url,
          "update" => url,
          "delete" => url
        },
        "uuid" => batch_uuid,
        "process" => nil,
        "kit" => nil
      }
    }
  end

  shared_context "set user and study uuid" do
    let(:study_uuid) { "55555555-2222-3333-6666-777777777777".tap do |uuid|
      store.with_session do |session|
        study = Lims::LaboratoryApp::Organization::Study.new
        set_uuid(session, study, uuid)
      end
    end
    } 

    let(:user_uuid) { "66666666-2222-4444-9999-000000000000".tap do |uuid|
      store.with_session do |session|
        user = Lims::LaboratoryApp::Organization::User.new(:email => user_email)
        set_uuid(session, user, uuid)
      end
    end
    }
  end 

  shared_examples_for "updated order" do
    it "succeeds to update the order" do
      update_action.status.should == 200 
    end

    it "returns the expected json" do
      update_action.body.should match_json(expected_json) 
    end

    it "update the object" do
      body = JSON::parse(update_action.body)
      body["order"]["uuid"].should == uuid
      body["order"]["actions"]["read"].should == "http://example.org#{url}"

      reloaded_order = get url
      reloaded_order.should match_json_response(200, expected_json)
    end
  end


  shared_context "save order" do |uuid|
    let!(:uuid) {
      store.with_session do |session|
        sources.each do |role, item_uuid|
          order.add_source(role, item_uuid)
        end
        targets.each do |role, item_uuid|
          order.add_target(role, item_uuid)
        end
        set_uuid(session, order, uuid)
        set_uuid(session, order.creator, user_uuid)
        set_uuid(session, order.study, study_uuid)
      end
      uuid
    }
  end


  shared_context "setup order" do |*events|
    let(:order) { 
      described_class.new(:creator => Organization::User.new(:email => user_email), :study => Organization::Study.new()).tap { |o| 
        if events
          events.each do |event|
            o.send(event)
          end
        end 
        }}
  end

  shared_context "with saved batch" do
    let(:batch_uuid) {
      "99999999-8888-7777-6666-555555555555".tap do |uuid|
        store.with_session do |session|
          batch = Lims::LaboratoryApp::Organization::Batch.new
          set_uuid(session, batch, uuid)
        end
      end
    }
  end

  shared_context "update order" do
    let(:update_action) { put url, update_parameters.to_json }  
  end

  shared_examples_for "doesn't accept event" do |event|
    context event do
      let(:update_parameters) { {:event => event} }
      include_context "update order"
      it { update_action.status.should == 500 }
    end
  end

  shared_examples_for "accept event and change status" do |event, status|
    context event do
      let(:update_parameters) { {:event => event} }
      include_context "update order"

      it "accept event" do
        update_action.status.should == 200 
      end

      it "change status" do
        body = JSON::parse(update_action.body)
        body["order"]["status"].should == status
      end 
    end 
  end

  shared_examples_for "modify order" do |event, status|
    context event do
      let(:update_parameters) { {:event => event}.merge(items_update) }
      include_context "update order"   
      include_context "json order"
      include_context "json batch"

      let(:order_status) { status }
      let(:order_parameters) { {} }
      let(:order_state) { {} }
      let(:order_pipeline) { order.pipeline }
      let(:order_cost_code) { order.cost_code }

      it_behaves_like "updated order"  
    end
  end

  shared_examples_for "updating variable" do |key, value|
    include_context "update order"
    context key do
      let(:update_parameters) { {key => value} }
      it {
        body = JSON::parse(update_action.body)
        body["order"][key.to_s].should == value
      }
    end
  end


  describe Organization::Order do
    def self.user_email 
      'creator@example.com'
    end
    let(:user_email) { self.class.user_email }

    include_context "use core context service", user_email
    include_context "JSON"

    context "#create" do
      include_context "set user and study uuid"

      context "with empty parameters" do
        let(:url) { "/actions/create_order" }
        let(:parameters) { {"create_order" => {} } }
        let(:expected_json) { {"errors" => {
          "study" => [
            "Study must not be blank"
          ],
            "cost_code"=> [
              "Cost code must not be blank"
          ]
        }} }
        it_behaves_like "an invalid core action", 422
      end

      context "with correct parameters" do
        include_context "use generated uuid"
        include_context "json order"
        let(:url) { "/orders" }
        let(:order_items) { {
          :source_role1 => [{"status" => "done", "uuid" => "99999999-2222-4444-9999-000000000000", "batch" => nil}],
          :target_role1 => [{"status" => "pending", "uuid" => "99999999-2222-4444-9999-111111111111", "batch" => nil}]} 
        }
        let(:order_parameters) { {} }
        let(:order_state) { {} }
        let(:order_status) { "draft" }
        let(:order_cost_code) { "cost code" }
        let(:order_pipeline) { "pipeline" }
        let(:sources) { {:source_role1 => ["99999999-2222-4444-9999-000000000000"]} }
        let(:targets) { {:target_role1 => ["99999999-2222-4444-9999-111111111111"]} }
        let(:parameters) { {:order => {:user_uuid => user_uuid, :study_uuid => study_uuid, :sources => sources, :targets => targets, :cost_code => order_cost_code, :pipeline => order_pipeline}} }
        it_behaves_like "a valid core action" do
        end 
      end
    end 

    context "#update" do
      include_context "save order", "11111111-2222-3333-4444-555555555555"
      let(:url) { "/#{uuid}" }
      let(:study_uuid) { "55555555-2222-3333-6666-777777777777" }
      let(:user_uuid) { "66666666-2222-4444-9999-000000000000" }
      let(:items_update) { {} }
      let(:sources) { {} }
      let(:targets) { {} }
      let(:order_items) { {} }

      context "draft order" do
        include_context "setup order"
       
        context "with no items" do
         it { order.status.should == "draft" }
          it_behaves_like "doesn't accept event", :start
          it_behaves_like "accept event and change status", :build, "pending"
          it_behaves_like "updating variable", :pipeline, "new pipeline"
          it_behaves_like "modify order", :build, "pending"
        end

        context "with items" do
         let(:sources) { {:source_role => ["44444444-0000-1111-2222-777777777777"]} }
         let(:targets) { {:target_role => ["44444444-2222-1111-2222-777777777777"]} }
         let(:order_items) { 
            {:source_role => [{"status" => "done", "uuid" => "44444444-0000-1111-2222-777777777777", "batch" => nil}],
             :new_role => [{"status" => "in_progress", "uuid" => "44444444-1111-1111-2222-777777777777", "batch" => nil}],
             :target_role => [{"status" => "pending", "uuid" => "44444444-2222-1111-2222-777777777777", "batch" => nil}]}
         }
         let(:items_update) { {:items => {:new_role => {"44444444-1111-1111-2222-777777777777" => {:event => :start}}}} }
         it_behaves_like "doesn't accept event", :start
         it_behaves_like "accept event and change status", :build, "pending"
         it_behaves_like "updating variable", :pipeline, "new pipeline"
         it_behaves_like "modify order", :build, "pending"
        end

        context "with items referenced by index" do
          let(:sources) { {:source_role => ["44444444-0000-1111-2222-777777777777"]} }
          let(:targets) { {:target_role => ["44444444-2222-1111-2222-777777777777"]} }
          let(:order_items) { 
            {:source_role => [{"status" => "done", "uuid" => "44444444-0000-1111-2222-777777777777", "batch" => nil}],
             :target_role => [{"status" => "in_progress", "uuid" => "44444444-2222-1111-2222-777777777777", "batch" => nil}, {"status" => "pending", "uuid" => "", "batch" => nil}]}
          }
          let(:items_update) { {:items => {:target_role => {"0" => {:event => :start}, "last" => {}}}} }
          it_behaves_like "modify order", :build, "pending"
        end

        context "with items assigned to a batch" do
          include_context "with saved batch"          
          let(:sources) { {:source_role => ["44444444-0000-1111-2222-777777777777"]} }
          let(:targets) { {:target_role => ["44444444-2222-1111-2222-777777777777"]} }
          let(:order_items) { 
            {:source_role => [{"status" => "done", "uuid" => "44444444-0000-1111-2222-777777777777", "batch" => nil}],
             :new_role => [{"status" => "in_progress", "uuid" => "44444444-1111-1111-2222-777777777777", "batch" => batch_json}],
             :target_role => [{"status" => "pending", "uuid" => "44444444-2222-1111-2222-777777777777", "batch" => nil}]}
          }
          let(:items_update) { {:items => {:new_role => {"44444444-1111-1111-2222-777777777777" => {:event => :start, :batch_uuid => batch_uuid}}}} }
          it_behaves_like "modify order", :build, "pending"
        end
      end

      context "pending order" do
        include_context "setup order", :build
        it { order.status.should == "pending" }
        it_behaves_like "doesn't accept event", :build
        it_behaves_like "accept event and change status", :start, "in_progress"
        it_behaves_like "modify order", :start, "in_progress"
      end

      context "in_progress order" do
        include_context "setup order", :build, :start

        context "with no items" do
          it { order.status.should == "in_progress" }
          it_behaves_like "doesn't accept event", :build
          it_behaves_like "accept event and change status", :complete, "completed"
          it_behaves_like "modify order", :complete, "completed"
        end

        context "with items" do
         let(:sources) { {:source_role => ["44444444-0000-1111-2222-777777777777"]} }
         let(:targets) { {:target_role => ["44444444-2222-1111-2222-777777777777"]} }
         let(:order_items) { 
            {:source_role => [{"status" => "unused", "uuid" => "44444444-0000-1111-2222-777777777777", "batch" => nil}],
             :new_role => [{"status" => "in_progress", "uuid" => "44444444-1111-1111-2222-777777777777", "batch" => nil}],
             :target_role => [{"status" => "pending", "uuid" => "44444444-2222-1111-2222-777777777777", "batch" => nil}]}
         }
         let(:items_update) { {:items => {:new_role => {"44444444-1111-1111-2222-777777777777" => {:event => :start}},
                                          :source_role => {"44444444-0000-1111-2222-777777777777" => {:event => :unuse}}}} }
         it { order.status.should == "in_progress" }
         it_behaves_like "doesn't accept event", :build
         it_behaves_like "accept event and change status", :complete, "completed"
         it_behaves_like "modify order", :complete, "completed"
        end
      end

      context "failed order" do
        include_context "setup order", :build, :start, :fail
        it { order.status.should == "failed" }
        it_behaves_like "doesn't accept event", :complete
      end

      context "completed order" do
        include_context "setup order", :build, :start, :complete
        it { order.status.should == "completed" }
        it_behaves_like "doesn't accept event", :complete
      end

      context "cancel order" do
        include_context "setup order", :build, :start, :cancel
        it { order.status.should == "cancel" }
        it_behaves_like "doesn't accept event", :start
      end
    end
  end
end
