class CreateProceedings < ActiveRecord::Migration[6.1]
  def change
    create_table :proceedings, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.integer :proceeding_case_id, null: true
      t.boolean :lead_proceeding, default: false, null: false
      t.string :ccms_code, null: false
      t.string :meaning, null: false
      t.string :description, null: false
      t.decimal :substantive_cost_limitation, null: false
      t.decimal :delegated_functions_cost_limitation, null: false
      t.string :substantive_scope_limitation_code, null: false
      t.string :substantive_scope_limitation_meaning, null: false
      t.string :substantive_scope_limitation_description, null: false
      t.string :delegated_functions_scope_limitation_code, null: false
      t.string :delegated_functions_scope_limitation_meaning, null: false
      t.string :delegated_functions_scope_limitation_description, null: false
      t.date :used_delegated_functions_on, null: false
      t.date :used_delegated_functions_reported_on, null: false
      t.timestamps
    end
  end
end
