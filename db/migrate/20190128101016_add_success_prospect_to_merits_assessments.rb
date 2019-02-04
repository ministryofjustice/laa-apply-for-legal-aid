class AddSuccessProspectToMeritsAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :merits_assessments, :success_prospect, :string
    add_column :merits_assessments, :success_prospect_details, :text
  end
end
