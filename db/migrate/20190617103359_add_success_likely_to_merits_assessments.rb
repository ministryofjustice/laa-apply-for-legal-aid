class AddSuccessLikelyToMeritsAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :merits_assessments, :success_likely, :boolean
  end
end
