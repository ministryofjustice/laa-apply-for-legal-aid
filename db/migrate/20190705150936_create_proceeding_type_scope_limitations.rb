class CreateProceedingTypeScopeLimitations < ActiveRecord::Migration[5.2]
  def change
    create_table :proceeding_type_scope_limitations, id: :uuid do |t|
      t.references :proceeding_type, type: :uuid, foreign_key: true
      t.references :scope_limitation, type: :uuid, foreign_key: true
      t.boolean :substantive_default
      t.boolean :delegated_functions_default
      t.timestamps
    end
  end
end
