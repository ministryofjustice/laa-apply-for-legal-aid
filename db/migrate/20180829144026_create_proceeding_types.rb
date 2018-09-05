class CreateProceedingTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :proceeding_types do |t|
      t.string :code, index: true
      t.string :ccms_code
      t.string :meaning
      t.string :description
      t.timestamps
    end
  end
end
