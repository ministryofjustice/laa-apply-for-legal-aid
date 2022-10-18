class AddApplicantInReceiptOfHousingBenefitToLegalAidApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :legal_aid_applications, :applicant_in_receipt_of_housing_benefit, :boolean, null: true
  end
end
