class AddRelatedOrdersToProceedings < ActiveRecord::Migration[7.2]
  def change
    add_column :proceedings, :related_orders, :string, array: true, null: false, default: []
  end
end
