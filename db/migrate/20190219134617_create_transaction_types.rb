class CreateTransactionTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :transaction_types, id: :uuid do |t|
      t.string :name
      t.string :operation
      t.timestamps
    end
  end
end
