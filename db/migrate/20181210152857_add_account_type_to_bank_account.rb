class AddAccountTypeToBankAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :account_type, :string
  end
end
