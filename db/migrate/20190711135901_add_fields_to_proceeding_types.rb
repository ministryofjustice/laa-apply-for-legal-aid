class AddFieldsToProceedingTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :proceeding_types, :default_level_of_service_id, :integer
    add_column :proceeding_types, :default_level_of_service_name, :string
    add_column :proceeding_types, :default_cost_limitation_delegated_functions, :integer
    add_column :proceeding_types, :default_cost_limitation_substantive, :integer
    add_column :proceeding_types, :involvement_type_applicant, :boolean
  end
end
