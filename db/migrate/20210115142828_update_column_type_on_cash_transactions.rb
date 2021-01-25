class UpdateColumnTypeOnCashTransactions < ActiveRecord::Migration[6.0]
  def change
    rename_column :cash_transactions, :transaction_type_id, :transaction_type_id_old
    add_column :cash_transactions, :transaction_type_id, :uuid
  end
end
