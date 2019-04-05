class AddApplicantMeansAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :applicant_means_answers, :json
  end
end
