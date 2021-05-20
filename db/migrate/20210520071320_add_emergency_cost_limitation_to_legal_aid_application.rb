class AddEmergencyCostLimitationToLegalAidApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :legal_aid_applications, :emergency_cost_override, :boolean
    add_column :legal_aid_applications, :emergency_cost_requested, :numeric
    add_column :legal_aid_applications, :emergency_cost_reasons, :string
  end
end
