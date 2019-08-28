class RemoveServiceLevelsTable < ActiveRecord::Migration[5.2]
  def up
    remove_column :proceeding_types, :default_service_level_id
    drop_table :service_levels
  end

  def down
    add_column :proceeding_types, :default_service_level_id, :integer
    create_table :service_levels, id: false, primary_key: :service_id do |t|
      t.primary_key :service_id
      t.string :name
      t.timestamps
    end
    add_foreign_key :proceeding_types, :service_levels, column: :default_service_level_id, primary_key: :service_id
  end
end
