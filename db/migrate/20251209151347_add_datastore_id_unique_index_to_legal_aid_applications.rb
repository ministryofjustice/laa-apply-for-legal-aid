class AddDatastoreIdUniqueIndexToLegalAidApplications < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :legal_aid_applications, :datastore_id, unique: true, algorithm: :concurrently
  end
end
