class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :application_proceeding_types, :proceeding_types
    add_foreign_key :application_proceeding_types, :legal_aid_applications
    add_foreign_key :legal_aid_applications, :applicants
  end
end
