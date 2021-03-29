class RenameMeritsAssessmentTable < ActiveRecord::Migration[6.1]
  def change
    rename_table :merits_assessments, :chances_of_successes
  end
end
