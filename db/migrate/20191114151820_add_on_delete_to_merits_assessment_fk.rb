class AddOnDeleteToMeritsAssessmentFk < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :merits_assessments, :legal_aid_applications
    add_foreign_key :merits_assessments, :legal_aid_applications, on_delete: :cascade
  end
end
