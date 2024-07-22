class AddSharedBenefitColumnToApplicant < ActiveRecord::Migration[7.1]
  def up
    add_column :applicants, :shared_benefit_with_partner, :boolean
    Partner.where.not(shared_benefit_with_applicant: nil).each do |partner|
      partner.legal_aid_application.applicant.update!(shared_benefit_with_partner: partner.shared_benefit_with_applicant)
    end
  end

  def down
    remove_column :applicants, :shared_benefit_with_partner
  end
end
