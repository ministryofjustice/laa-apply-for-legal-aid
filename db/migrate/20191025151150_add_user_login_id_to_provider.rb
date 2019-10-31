class AddUserLoginIdToProvider < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :user_login_id, :string
  end
end
