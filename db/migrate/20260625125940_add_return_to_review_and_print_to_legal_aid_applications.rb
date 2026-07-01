class AddReturnToReviewAndPrintToLegalAidApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :legal_aid_applications, :return_to_review_and_print, :boolean, null: false, default: false
  end
end
