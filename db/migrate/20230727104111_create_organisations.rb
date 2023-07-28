class CreateOrganisations < ActiveRecord::Migration[7.0]
  def change
    create_table :organisations, id: :uuid do |t|
      t.string "name", null: false
      t.string "ccms_code", null: false
      t.string "description", null: false
      t.timestamps
    end
  end
end
