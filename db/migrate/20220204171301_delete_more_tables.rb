class DeleteMoreTables < ActiveRecord::Migration[6.1]
  def up
    drop_table :application_proceeding_types_linked_children, force: :cascade
    drop_table :default_cost_limitations, force: :cascade
    drop_table :service_levels, force: :cascade
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
