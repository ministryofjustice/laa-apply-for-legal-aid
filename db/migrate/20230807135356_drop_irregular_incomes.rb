class DropIrregularIncomes < ActiveRecord::Migration[7.0]
  def change
    drop_table :irregular_incomes
  end
end
