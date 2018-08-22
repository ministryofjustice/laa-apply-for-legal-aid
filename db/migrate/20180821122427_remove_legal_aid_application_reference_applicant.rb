class RemoveLegalAidApplicationReferenceApplicant < ActiveRecord::Migration[5.2]
  def change
    remove_reference :applicants, :legal_aid_application, index: true
  end
end
