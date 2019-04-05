class SetApplicationRefUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :legal_aid_applications, :application_ref, unique: true
  end
end
