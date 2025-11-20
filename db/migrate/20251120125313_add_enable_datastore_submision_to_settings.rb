class AddEnableDatastoreSubmisionToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :enable_datastore_submission, :boolean, null: false, default: false
  end
end
