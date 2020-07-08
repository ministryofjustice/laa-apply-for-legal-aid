class CreateRolesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :role
      t.string :description
    end

    add_index :roles, :role, unique: true
  end
end
