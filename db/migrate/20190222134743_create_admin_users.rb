class CreateAdminUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_users, id: :uuid do |t|
      t.string :username,           null: false, default: ''
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      # Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      # Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.datetime :locked_at

      t.timestamps
    end
  end
end
