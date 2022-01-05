class RemoveApplicantMeansAnswers < ActiveRecord::Migration[6.1]
  def change
    remove_column :legal_aid_applications, :applicant_means_answers, :json
  end
end
