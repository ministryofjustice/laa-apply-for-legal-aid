class CreateVaryOrder < ActiveRecord::Migration[7.0]
  def change
    create_table :vary_orders, id: :uuid do |t|
      t.belongs_to :proceeding, null: false, foreign_key: true, type: :uuid
      t.string :details

      t.timestamps
    end
  end
end
