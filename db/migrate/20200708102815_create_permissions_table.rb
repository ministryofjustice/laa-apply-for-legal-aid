class CreatePermissionsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :permissions, id: :uuid do |t|
      t.string :role
      t.string :description
    end

    add_index :permissions, :role, unique: true

    require Rails.root.join('db/seeds/permissions')
    PermissionsPopulator.run
  end
end
