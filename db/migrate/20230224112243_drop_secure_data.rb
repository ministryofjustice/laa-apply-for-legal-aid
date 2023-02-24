class DropSecureData < ActiveRecord::Migration[7.0]
  def change
    drop_table :secure_data, force: :cascade, if_exists: true, primary_key: :id, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.text :data, null: true
      t.timestamps
    end
  end
end
