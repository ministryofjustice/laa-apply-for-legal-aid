class AddTransactionFileNameToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :bank_transaction_filename, :string, default: 'db/sample_data/bank_transactions.csv'
  end
end
