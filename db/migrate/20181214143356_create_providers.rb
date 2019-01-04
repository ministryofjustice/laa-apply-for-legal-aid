class CreateProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :providers, id: :uuid do |t|
      t.string :username, null: false
      t.string :type
      t.text :roles

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      t.timestamps
    end

    add_index :providers, :username, unique: true
    add_index :providers, :type
  end
end
