class AddProceedingsBeforeTheCourtToMeritsAssessment < ActiveRecord::Migration[5.2]
  def change
    add_column :merits_assessments, :proceedings_before_the_court, :boolean
    add_column :merits_assessments, :details_of_proceedings_before_the_court, :text
  end
end
