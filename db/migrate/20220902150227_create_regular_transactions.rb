class CreateRegularTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :regular_transactions, id: :uuid do |t|
      t.references :legal_aid_application, null: false, foreign_key: { on_delete: :cascade }, index: false, type: :uuid
      t.references :transaction_type, null: false, foreign_key: true, index: false, type: :uuid
      t.decimal :amount, null: false
      t.string :frequency, null: false
      t.timestamps
    end
  end
end
