require 'models/persistence/spec_helper'
require 'lims-core/persistence/sequel/persistor'

module Helper
def save(object)
  store.with_session do |session|
    session << object
    lambda { session.id_for(object) }
  end.call 
end
end

RSpec.configure do |c|
  c.include Helper
end


