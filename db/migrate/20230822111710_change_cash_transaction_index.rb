class ChangeCashTransactionIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :cash_transactions, name: :cash_transactions_unique
    add_index :cash_transactions, [:legal_aid_application_id, :owner_id, :transaction_type_id, :month_number], unique: true, name: "cash_transactions_unique", algorithm: :concurrently
  end
end
