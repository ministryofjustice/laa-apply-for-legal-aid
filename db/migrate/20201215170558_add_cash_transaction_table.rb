class AddCashTransactionTable < ActiveRecord::Migration[6.0]
  def change
    create_table :cash_transactions, id: :uuid do |t|
      t.string :legal_aid_application_id
      t.decimal :amount
      t.date :transaction_date
      t.string :transaction_type_id
      t.timestamps
    end
  end
end
