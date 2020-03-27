class AddMetaDataToBankTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_transactions, :meta_data, :string
  end
end
