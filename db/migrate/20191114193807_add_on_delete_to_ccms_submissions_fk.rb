class AddOnDeleteToCCMSSubmissionsFk < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :ccms_submissions, :legal_aid_applications
    add_foreign_key :ccms_submissions, :legal_aid_applications, on_delete: :cascade
  end
end
