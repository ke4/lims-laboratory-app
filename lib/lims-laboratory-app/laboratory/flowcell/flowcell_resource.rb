#flowcell_resource.rb
require 'lims-api/core_resource'
require 'lims-api/struct_stream'

require 'lims-laboratory-app/labellable_core_resource'
require 'lims-laboratory-app/laboratory/flowcell'
require 'lims-laboratory-app/laboratory/container'
require 'lims-laboratory-app/laboratory/container/receptacle'

module Lims::LaboratoryApp
  module Laboratory
    class Flowcell
      class FlowcellResource < LabellableCoreResource

        include Lims::LaboratoryApp::Laboratory::Container::Receptacle

        def content_to_stream(s, mime_type)
          super(s, mime_type)
          s.add_key "number_of_lanes"
          s.add_value object.number_of_lanes 
          s.add_key "lanes"
          lanes_to_stream(s, mime_type)
        end

        def lanes_to_stream(s, mime_type)
          s.start_hash
          object.each_with_index do |lane, id|
            s.add_key(id+1).to_s
            receptacle_to_stream(s, lane, mime_type)
          end
          s.end_hash
        end

      end
    end
  end
end
