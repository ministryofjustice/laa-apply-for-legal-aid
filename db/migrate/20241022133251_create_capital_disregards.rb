class CreateCapitalDisregards < ActiveRecord::Migration[7.2]
  def change
    create_table :capital_disregards, id: :uuid do |t|
      t.belongs_to :legal_aid_application, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.boolean :mandatory, null: false
      t.decimal :amount
      t.date :date_received
      t.string :payment_reason
      t.string :account_name
      t.timestamps
    end
  end
end
