class AddRunningBalanceToBankTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_transactions, :running_balance, :decimal
  end
end
