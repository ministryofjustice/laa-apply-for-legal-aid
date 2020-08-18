class RemoveUserLoginFromProvider < ActiveRecord::Migration[6.0]
  def change
    remove_column :providers, :user_login_id, :string
  end
end
