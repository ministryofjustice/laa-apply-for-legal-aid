class RemoveTokenExpiresAtFromBankProviders < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :bank_providers, :token_expires_at, :datetime, null: true }
  end
end
