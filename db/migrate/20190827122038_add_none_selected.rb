class AddNoneSelected < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :no_credit_transaction_types_selected, :boolean
    add_column :legal_aid_applications, :no_debit_transaction_types_selected, :boolean
    add_column :savings_amounts, :none_selected, :boolean
    add_column :other_assets_declarations, :none_selected, :boolean
  end
end
