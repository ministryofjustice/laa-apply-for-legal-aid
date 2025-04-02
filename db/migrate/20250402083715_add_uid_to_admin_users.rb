class AddUidToAdminUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :admin_users, :uid, :string
    add_index :admin_users, :uid, unique: true, algorithm: :concurrently
  end
end
