class UpdateProceedingFields < ActiveRecord::Migration[7.0]
  def change
    change_column_null :proceedings, :substantive_scope_limitation_code, true
    change_column_null :proceedings, :substantive_scope_limitation_meaning, true
    change_column_null :proceedings, :delegated_functions_scope_limitation_code, true
    change_column_null :proceedings, :substantive_scope_limitation_description, true
    change_column_null :proceedings, :delegated_functions_scope_limitation_meaning, true
    change_column_null :proceedings, :delegated_functions_scope_limitation_description, true
    change_table :proceedings, bulk: true do |t|
      t.integer :emergency_level_of_service
      t.string :emergency_level_of_service_name
      t.integer :emergency_level_of_service_stage
      t.integer :substantive_level_of_service
      t.string :substantive_level_of_service_name
      t.integer :substantive_level_of_service_stage
      t.boolean :accepted_emergency_defaults
      t.boolean :accepted_substantive_defaults
    end
    Proceeding.update_all(substantive_level_of_service: 3,
                          substantive_level_of_service_name: "Full Representation",
                          substantive_level_of_service_stage: 8,
                          emergency_level_of_service: 3,
                          emergency_level_of_service_name: "Full Representation",
                          emergency_level_of_service_stage: 8,
                          accepted_substantive_defaults: true,
                          accepted_emergency_defaults: true)
  end
end
