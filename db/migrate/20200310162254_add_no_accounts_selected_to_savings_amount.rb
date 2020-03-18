class AddNoAccountsSelectedToSavingsAmount < ActiveRecord::Migration[6.0]
  def change
    add_column :savings_amounts, :no_account_selected, :boolean
  end
end
