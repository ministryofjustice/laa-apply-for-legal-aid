class AddFlagsToBankTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_transactions, :flags, :json
  end
end
