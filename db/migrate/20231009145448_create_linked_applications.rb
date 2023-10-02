class CreateLinkedApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :linked_applications, id: :uuid do |t|
      t.references :lead_application, type: :uuid, null: false
      t.references :associated_application, type: :uuid, null: false  
      t.string :link_type_description, null: false
      t.string :link_type_code, null: false

      t.timestamps
    end

    add_foreign_key :linked_applications, :legal_aid_applications, column: :lead_application_id, validate: false
    add_foreign_key :linked_applications, :legal_aid_applications, column: :associated_application_id, validate: false
    add_index :linked_applications, %w[lead_application_id associated_application_id], name: "index_linked_applications", unique: true
  end
end
