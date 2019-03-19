class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings, id: :uuid do |t|
      t.timestamps

      t.boolean :mock_true_layer_data, null: false, default: false
    end
  end
end
