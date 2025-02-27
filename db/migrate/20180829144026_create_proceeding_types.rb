class CreateProceedingTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :proceeding_types, id: :uuid do |t|
      t.string :code, index: true
      t.string :ccms_code
      t.string :meaning
      t.string :description
      t.timestamps
    end
  end
end
