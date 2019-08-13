class CreateBenefitTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :benefit_types, id: :uuid do |t|
      t.string :label
      t.text :description
      t.boolean :exclude_from_gross_income

      t.timestamps
    end
  end
end
