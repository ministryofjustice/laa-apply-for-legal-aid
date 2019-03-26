class AddExpiredAtToSecureData < ActiveRecord::Migration[5.2]
  def change
    add_column :secure_data, :expired_at, :datetime
  end
end
