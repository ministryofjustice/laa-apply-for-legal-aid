class AddHasPartnerToApplicant < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :has_partner, :boolean

    Applicant.update_all(has_partner: false)
  end
end
