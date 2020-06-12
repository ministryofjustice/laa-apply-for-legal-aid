class CreateIrregularIncomes < ActiveRecord::Migration[6.0]
  def change
    create_table :irregular_incomes, id: :uuid do |t|
      t.string :legal_aid_application_id
      t.string :income_type
      t.string :frequency
      t.decimal :amount
      t.timestamps
    end
  end
end
