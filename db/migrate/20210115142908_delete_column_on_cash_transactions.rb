class DeleteColumnOnCashTransactions < ActiveRecord::Migration[6.0]
  def change
    remove_column :cash_transactions, :transaction_type_id_old, :string
  end
end
