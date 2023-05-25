class AddSharedBenefitColumnToPartner < ActiveRecord::Migration[7.0]
  def change
    add_column :partners, :shared_benefit_with_applicant, :boolean
  end
end
