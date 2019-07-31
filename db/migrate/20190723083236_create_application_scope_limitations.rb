class CreateApplicationScopeLimitations < ActiveRecord::Migration[5.2]
  def change
    create_table :application_scope_limitations, id: :uuid do |t|
      t.uuid :legal_aid_application_id
      t.uuid :scope_limitation_id
      t.boolean :substantive, default: true
      t.timestamps
    end

    add_index :application_scope_limitations, :legal_aid_application_id
  end
end
