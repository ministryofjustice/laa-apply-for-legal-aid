class AddIncomeToDependants < ActiveRecord::Migration[5.2]
  def change
    add_column :dependants, :monthly_income, :decimal
    add_column :dependants, :has_income, :boolean
  end
end
