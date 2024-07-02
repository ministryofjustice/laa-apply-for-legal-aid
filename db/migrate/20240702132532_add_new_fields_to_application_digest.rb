class AddNewFieldsToApplicationDigest < ActiveRecord::Migration[7.1]
  def change
    add_column :application_digests, :has_partner, :boolean
    add_column :application_digests, :contrary_interest, :boolean
    add_column :application_digests, :partner_dwp_challenge, :boolean
    add_column :application_digests, :applicant_age, :integer
    add_column :application_digests, :non_means_tested, :boolean
  end
end
