class AddApplicantReferenceLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_reference :legal_aid_applications, :applicant, index: true
  end
end
