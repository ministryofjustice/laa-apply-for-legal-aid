class AddPartnerHasContraryInterestToApplicants < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :partner_has_contrary_interest, :boolean
  end
end
