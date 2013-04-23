# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims-core/persistence/persistor'
require 'lims-core/laboratory/aliquot'
require 'lims-core/laboratory/sample/sample_persistor'

module Lims::Core
  module Laboratory
    # @abstract
    # Base for all Aliquot persistor.
    # Real implementation classes (e.g. Sequel::Aliquot) should
    # include the suitable persistor.
    class Aliquot
      class AliquotPersistor < Persistence::Persistor
        Model = Laboratory::Aliquot
      end
    end
  end
end
