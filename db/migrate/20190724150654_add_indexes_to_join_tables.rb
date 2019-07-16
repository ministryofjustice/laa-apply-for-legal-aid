class AddIndexesToJoinTables < ActiveRecord::Migration[5.2]
  def change
    add_index :application_proceeding_types, %i[legal_aid_application_id proceeding_type_id], unique: true, name: 'app_proceeding_type_index'
    add_index :application_scope_limitations, %i[legal_aid_application_id scope_limitation_id], unique: true, name: 'scope_limitations_index'
  end
end
