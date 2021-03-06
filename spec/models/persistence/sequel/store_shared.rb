
# Spec requirements
require 'models/spec_helper'

# Model requirements
require 'sequel'
require 'lims-core/persistence/sequel/store'
Sequel.extension :migration

shared_context "prepare tables" do
  def prepare_table(db)
    Sequel::Migrator.run(db, 'db/migrations')
  end
end

Loggers = []
#require 'logger'; Loggers << Logger.new($stdout)

shared_context "sequel store" do
    include_context "prepare tables"
    include_context "sqlite store"
    before (:each) { prepare_table(db) }

end
