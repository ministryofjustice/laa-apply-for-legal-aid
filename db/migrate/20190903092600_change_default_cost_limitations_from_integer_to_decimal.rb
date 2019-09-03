class ChangeDefaultCostLimitationsFromIntegerToDecimal < ActiveRecord::Migration[5.2]
  def up
    change_column :proceeding_types, :default_cost_limitation_substantive, :decimal, precision: 8, scale: 2
    change_column :proceeding_types, :default_cost_limitation_delegated_functions, :decimal, precision: 8, scale: 2
  end

  def down
    change_column :proceeding_types, :default_cost_limitation_substantive, :integer
    change_column :proceeding_types, :default_cost_limitation_delegated_functions, :integer
  end
end
