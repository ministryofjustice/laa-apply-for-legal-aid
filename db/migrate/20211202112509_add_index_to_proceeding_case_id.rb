class AddIndexToProceedingCaseId < ActiveRecord::Migration[6.1]
  def change
    change_table :proceedings do |t|
      t.index :proceeding_case_id, unique: true
    end
  end
end
