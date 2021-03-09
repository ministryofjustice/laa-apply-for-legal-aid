class AddUniqueIndexToDWPOverrides < ActiveRecord::Migration[6.1]
  def change
    remove_index :dwp_overrides, name: :index_dwp_overrides_on_legal_aid_application_id
    add_index :dwp_overrides, :legal_aid_application_id, unique: true
  end
end
