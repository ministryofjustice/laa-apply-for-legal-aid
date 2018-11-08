class CreateSecureData < ActiveRecord::Migration[5.2]
  def change
    create_table :secure_data, id: :uuid do |t|
      t.text :data

      t.timestamps
    end
  end
end
