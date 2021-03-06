# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'

require 'lims-laboratory-app/organization/order'

module Lims::LaboratoryApp
  module Organization
    class Order
      class UpdateOrder
        include Lims::Core::Actions::Action

        #@ attribute :order
        #  The order to update.
        attribute :order, Organization::Order
        # @attribute :items
        #   a Hash of Hash of Items to *add* or *update*
        #   key are the role name
        #   value are a Hash of items with
        #      key being either the item uuid, #   and index, or last for insert
        #      value either a uuid (String) or an event (Symbol) to send to the current item.
        # {:role => {'11111111-1111-2222-3333-444444444444' => 
        #     {:event => :start,
        #      :batch_uuid => '111111111-0000-0000-0000-111111111111'}}}
        # or
        # {:role => {'1' => {:event => :start}}}
        attribute :items, Hash , :default => {}
        attribute :event, Symbol 
        attribute :pipeline, String
        attribute :study, Organization::Study
        attribute :creator, Organization::User
        attribute :cost_code, String
        attribute :parameters, Hash
        attribute :state, Hash

        def _call_in_session(session)
          items.each { |role, args| update_item(role, args) }
          if event.present?
            order.public_send("#{event}!")
          end
          %w[pipeline creator cost_code study parameters state].each do |key|
            value = self[key]
            order[key] = value if value
          end
          {:order => order }
        end

        def update_item(role, args)
          items = order.fetch(role) { |k|  order[k]= [] }

          args.each do |key, item_args|
            item = case key
            when /\A\d+\z/
              items[key.to_i]
            when "last"
              Organization::Order::Item.new.tap { |item|  items << item }
            when Lims::Core::Persistence::UuidResource::ValidationRegexp #uuid
              # Lookup item by uuid
              # If we don't find it
              # we need to create it and add it.
              # If there are two, we raise an error.
              founds = items.select { |i| i.uuid == key }
              case founds.size
              when 0
                Organization::Order::Item.new(:uuid => key).tap { |item| items << item }
              when 1
                founds.first
              else
                raise InvalidParameters, "there are too many items with the uuid #{key} for role '#{role}'"
              end
            else
              raise InvalidParameters, {:role => "Item index '#{key}' not a valid uuid or number for role '#{role}'"}

            end

            item_args["uuid"].andtap { |uuid| item.uuid = uuid }
            item_args["event"].andtap { |event| item.public_send("#{event}!") }
            item_args["batch"].andtap { |batch| item.batch = batch }
          end
        end
      end
    end
  end

  module Organization
    class Order
      Update = UpdateOrder
    end
  end
end
