class AddFieldsToApplicationDigest < ActiveRecord::Migration[7.1]
  def change
    add_column :application_digests, :family_linked, :boolean
    add_column :application_digests, :family_linked_lead_or_associated, :string
    add_column :application_digests, :number_of_family_linked_applications, :integer
    add_column :application_digests, :legal_linked, :boolean
    add_column :application_digests, :legal_linked_lead_or_associated, :string
    add_column :application_digests, :number_of_legal_linked_applications, :integer
  end
end
