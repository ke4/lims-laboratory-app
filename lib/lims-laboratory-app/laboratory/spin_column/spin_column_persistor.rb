require 'lims-core/persistence/persistor'
require 'lims-core/laboratory/spin_column'

module Lims::Core
  module Laboratory

    # Base for all Spin Column persistor.
    # Real implementation classes (e.g. Sequel::SpinColumn) should
    # include the suitable persistor.
    class SpinColumn
      module SpinColumnAliquot
        SESSION_NAME = :spin_column_persistor_aliquot
        class SpinColumnAliquotPersistor < Persistence::Persistor
        end
      end
      class SpinColumnPersistor < Persistence::Persistor
        Model = Laboratory::SpinColumn

        # Save all children of the given spin column
        # @param  id object identifier
        # @param [Laboratory::SpinColumn] spin column
        # @return [Boolean]
        def save_children(id, spin_column)
          # we use values here, so position is a number
          spin_column.each do |aliquot|
            spin_column_aliquot.save_as_aggregation(id, aliquot)
          end
        end

        def  spin_column_aliquot
          @session.spin_column_persistor_aliquot
        end


        # Load all children of the given spin column
        # Loaded object are automatically added to the session.
        # @param  id object identifier
        # @param [Laboratory::SpinColumn] spin column
        # @return [Laboratory::SpinColumn, nil] 
        #
        def load_children(id, spin_column)
          spin_column_aliquot.load_aliquots(id) do |aliquot|
            spin_column << aliquot
          end
        end
      end
    end
  end
end
