class DropRestrictionsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :restrictions, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
