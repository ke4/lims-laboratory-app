require 'common'
require 'lims-laboratory-app/laboratory/locatable_resource'
require 'lims-laboratory-app/laboratory/receptacle.rb'

module Lims::LaboratoryApp
  module Laboratory
    # Piece of labware. 
    # Can have something on it.
    # It can have a label (barcode) to identify it.
    class SpinColumn
      include LocatableResource
      include Receptacle
    end
  end
end
