class CreateRolesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :apply_system_roles, id: :uuid do |t|
      t.string :role
      t.string :description
    end

    add_index :apply_system_roles, :role, unique: true
  end
end
