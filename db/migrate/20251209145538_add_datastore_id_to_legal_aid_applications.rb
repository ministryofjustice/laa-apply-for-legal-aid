class AddDatastoreIdToLegalAidApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :legal_aid_applications, :datastore_id, :uuid
  end
end
