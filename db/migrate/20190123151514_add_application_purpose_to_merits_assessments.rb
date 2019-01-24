class AddApplicationPurposeToMeritsAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :merits_assessments, :application_purpose, :text
  end
end
