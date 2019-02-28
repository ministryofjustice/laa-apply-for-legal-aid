class AddSortOrderToTransactionTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :transaction_types, :sort_order, :integer
  end
end
