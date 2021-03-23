class DropTableApplicationScopeLimitations < ActiveRecord::Migration[6.1]
  def up
    drop_table :application_scope_limitations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
