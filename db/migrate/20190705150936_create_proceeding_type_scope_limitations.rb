class CreateProceedingTypeScopeLimitations < ActiveRecord::Migration[5.2]
  def change
    create_table :proceeding_type_scope_limitations, id: :uuid do |t|
      t.references :proceeding_type, type: :uuid, foreign_key: true
      t.references :scope_limitation, type: :uuid, foreign_key: true
      t.boolean :substantive_default
      t.boolean :delegated_functions_default
      t.timestamps
    end

    add_index :proceeding_type_scope_limitations,
              %i[proceeding_type_id scope_limitation_id],
              unique: true,
              name: 'index_proceedings_scopes_unique_on_ids'

    add_index :proceeding_type_scope_limitations,
              %i[proceeding_type_id substantive_default],
              unique: true,
              where: 'substantive_default = true',
              name: 'index_proceedings_scopes_unique_substantive_default'

    add_index :proceeding_type_scope_limitations,
              %i[proceeding_type_id delegated_functions_default],
              unique: true,
              where: 'delegated_functions_default = true',
              name: 'index_proceedings_scopes_unique_delegated_default'
  end
end
