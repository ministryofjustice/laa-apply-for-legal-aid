class CreatePermissionsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :permissions, id: :uuid do |t|
      t.string :role
      t.string :description
    end

    add_index :permissions, :role, unique: true
  end
end
