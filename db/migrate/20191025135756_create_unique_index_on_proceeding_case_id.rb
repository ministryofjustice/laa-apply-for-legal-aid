class CreateUniqueIndexOnProceedingCaseId < ActiveRecord::Migration[5.2]
  def change
    add_index :application_proceeding_types, :proceeding_case_id, unique: true
  end
end
