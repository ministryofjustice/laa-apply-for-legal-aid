class AddOutstandingMortgageAmountToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :outstanding_mortgage_amount, :decimal
  end
end
