require 'lims-core/persistence/persistor'
require 'lims-core/laboratory/container/container_persistor'
require 'lims-core/laboratory/container/container_element_persistor'
require 'lims-core/laboratory/gel'

module Lims::Core
  module Laboratory

    # Base for all Gel persistor.
    # Real implementation classes (e.g. Sequel::Gel) should
    # include the suitable persistor.
    class Gel
      class GelPersistor < Persistence::Persistor
        Model = Laboratory::Gel

        include Container::ContainerPersistor

        # calls the correct element method
        def element
          window
        end

        def window
          @session.gel_window
        end
      end

        # Base for all Window persistor.
        # Real implementation classes (e.g. Sequel::Window) should
        # include the suitable persistor.
      class Window 
        SESSION_NAME = :gel_window
        class WindowPersistor < Persistence::Persistor
          Model = Laboratory::Gel::Window

          include Container::ContainerElementPersistor

        end
      end
    end
  end
end
