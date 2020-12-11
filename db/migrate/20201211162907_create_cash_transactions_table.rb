class CreateCashTransactionsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :cash_transactions, id: :uuid do |t|
      t.uuid :legal_aid_application_id
      t.uuid :transaction_type_id
      t.string :type
      t.decimal :amount

      t.timestamps
    end
  end
end
