require 'lims-core/actions/action'
require 'lims-core/laboratory/spin_column'

module Lims::Core
  module Laboratory
    class SpinColumn
      class CreateSpinColumn
        include Actions::Action

        attribute :aliquots, Array, :default => []

        def initialize(*args, &block)
          @name = "Create Spin Column"
          super(*args, &block)
        end

        def _call_in_session(session)
          spin_column = Laboratory::SpinColumn.new()
          session << spin_column
          aliquots.each do |aliquot|
            spin_column << Laboratory::Aliquot.new(aliquot)
          end
          { :spin_column => spin_column, :uuid => session.uuid_for!(spin_column) }
        end
      end
    end
  end

  module Laboratory
    class SpinColumn
      Create = CreateSpinColumn
    end
  end
end
