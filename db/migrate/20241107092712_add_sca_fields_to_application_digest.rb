class AddSCAFieldsToApplicationDigest < ActiveRecord::Migration[7.2]
  def change
    add_column :application_digests, :biological_parent, :boolean
    add_column :application_digests, :parental_responsibility_agreement, :boolean
    add_column :application_digests, :parental_responsibility_court_order, :boolean
    add_column :application_digests, :child_subject, :boolean
    add_column :application_digests, :parental_responsibility_evidence, :boolean
    add_column :application_digests, :autogranted, :boolean
  end
end
