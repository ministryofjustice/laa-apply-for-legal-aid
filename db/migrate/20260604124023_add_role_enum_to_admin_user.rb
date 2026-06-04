class AddRoleEnumToAdminUser < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_users, :role, :string, default: :digest_only
  end
end
