class AddTransactionTypesToBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_reference :bank_transactions, :transaction_type, index: true, type: :uuid
  end
end
