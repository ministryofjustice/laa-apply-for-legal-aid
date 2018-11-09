class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :type

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :type
  end
end
