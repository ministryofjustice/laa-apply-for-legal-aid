class DropCostLimitationsFromProceedingTypes < ActiveRecord::Migration[6.1]
  def change
    remove_column :proceeding_types, :default_cost_limitation_delegated_functions, :decimal
    remove_column :proceeding_types, :default_cost_limitation_substantive, :decimal
  end
end
