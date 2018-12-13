class AddSharedOwnershipToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :shared_ownership, :string
  end
end
