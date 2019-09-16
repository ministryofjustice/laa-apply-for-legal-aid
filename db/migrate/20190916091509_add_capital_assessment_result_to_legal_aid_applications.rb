class AddCapitalAssessmentResultToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :capital_assessment_result, :string
  end
end
