class CreateServiceLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :service_levels, id: false, primary_key: :service_id do |t|
      t.primary_key :service_id
      t.string :name
      t.timestamps
    end
    add_foreign_key :proceeding_types, :service_levels, column: :default_service_level_id, primary_key: :service_id
  end
end
