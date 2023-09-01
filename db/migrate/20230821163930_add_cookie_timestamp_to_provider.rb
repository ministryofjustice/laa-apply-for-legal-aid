class AddCookieTimestampToProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :cookies_saved_at, :datetime
  end
end
