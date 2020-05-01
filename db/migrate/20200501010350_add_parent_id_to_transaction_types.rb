class AddParentIdToTransactionTypes < ActiveRecord::Migration[6.0]
  def up
    add_column :transaction_types, :parent_id, :string, default: nil
    add_index :transaction_types, :parent_id, unique: false
  end

  def down
    remove_index :transaction_types, name: 'index_transaction_types_on_parent_id'
    remove_column :transaction_types, :parent_id
  end
end
