class RenameIsaToOfflineAccounts < ActiveRecord::Migration[5.2]
  def change
    rename_column :savings_amounts, :isa, :offline_accounts
  end
end
