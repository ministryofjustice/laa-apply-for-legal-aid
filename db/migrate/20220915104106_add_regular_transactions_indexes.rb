class AddRegularTransactionsIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :regular_transactions, :legal_aid_application_id, algorithm: :concurrently
    add_index :regular_transactions, :transaction_type_id, algorithm: :concurrently
  end
end
