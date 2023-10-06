class AddJointAccountsToSavingsAmounts < ActiveRecord::Migration[7.0]
  def change
    add_column :savings_amounts, :joint_offline_current_accounts, :numeric
    add_column :savings_amounts, :joint_offline_savings_accounts, :numeric
  end
end
