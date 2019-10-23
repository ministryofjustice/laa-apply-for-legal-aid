class AddColumnAndRenameExistingOnSavingsAmounts < ActiveRecord::Migration[5.2]
  def change
    add_column :savings_amounts, :offline_savings_accounts, :numeric
    rename_column :savings_amounts, :offline_accounts, :offline_current_accounts
  end
end
