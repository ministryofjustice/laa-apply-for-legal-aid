class RecreateServiceLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :service_levels, id: :uuid do |t|
      t.integer :service_level_number
      t.string :name
      t.timestamps
    end
    add_index :service_levels, :service_level_number
  end
end
