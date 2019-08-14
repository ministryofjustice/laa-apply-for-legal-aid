class AddProceedingCaseIdToApplicationProceedingTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :application_proceeding_types, :proceeding_case_id, :integer, null: true
  end
end
