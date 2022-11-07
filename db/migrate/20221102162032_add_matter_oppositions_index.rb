class AddMatterOppositionsIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :matter_oppositions, :legal_aid_application_id, algorithm: :concurrently
  end
end
