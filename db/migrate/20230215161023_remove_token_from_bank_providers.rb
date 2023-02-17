class RemoveTokenFromBankProviders < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :bank_providers, :token, :string, null: true }
  end
end
