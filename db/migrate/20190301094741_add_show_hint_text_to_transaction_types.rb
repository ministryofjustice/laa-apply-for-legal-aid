class AddShowHintTextToTransactionTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :transaction_types, :show_hint_text, :boolean, default: false
  end
end
