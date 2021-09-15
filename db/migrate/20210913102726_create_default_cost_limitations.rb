class CreateDefaultCostLimitations < ActiveRecord::Migration[6.1]
  def change
    create_table :default_cost_limitations, id: :uuid do |t|
      t.belongs_to :proceeding_type, foreign_key: true, null: false, type: :uuid
      t.date :start_date, null: false
      t.string :cost_type, null: false
      t.decimal :value, null: false

      t.timestamps
    end
  end
end
