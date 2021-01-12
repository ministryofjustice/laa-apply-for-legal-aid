class AddMonthNumberToCashTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :cash_transactions, :month_number, :integer

    add_index :cash_transactions, %i[legal_aid_application_id transaction_type_id month_number], unique: true, name: 'cash_transactions_unique'
  end
end
