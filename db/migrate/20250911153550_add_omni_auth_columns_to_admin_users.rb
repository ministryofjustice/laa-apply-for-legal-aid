class AddOmniAuthColumnsToAdminUsers < ActiveRecord::Migration[8.0]
  def change
    # Omniauthable, custom devise
    add_column :admin_users, :auth_provider, :string, null: false, default: ""
    add_column :admin_users, :auth_subject_uid, :string
  end
end
