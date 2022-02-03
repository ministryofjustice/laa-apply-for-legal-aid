class DropProceedingType < ActiveRecord::Migration[6.1]
  def up
    drop_table :application_proceeding_types, force: :cascade
    drop_table :proceeding_types, force: :cascade
    drop_table :scope_limitations, force: :cascade
    drop_table :proceeding_type_scope_limitations, force: :cascade
    drop_table :application_proceeding_types_scope_limitations, force: :cascade
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
