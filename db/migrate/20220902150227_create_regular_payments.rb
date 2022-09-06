class CreateRegularPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :regular_payments, id: :uuid do |t|
      t.references :legal_aid_application, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :transaction_type, null: false, foreign_key: true, type: :uuid
      t.decimal :amount, null: false
      t.string :frequency, null: false
      t.timestamps
    end
  end
end
