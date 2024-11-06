class CreateFeatureFlag < ActiveRecord::Migration[7.2]
  def change
    create_table :feature_flags, id: :uuid do |t|
      t.string :name
      t.text :description
      t.boolean :active
      t.datetime :start_at

      t.timestamps
    end
  end
end
