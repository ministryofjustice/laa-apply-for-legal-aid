class CreateLegalAidApplicationProceedings < ActiveRecord::Migration[5.2]
  def change
    create_table :application_proceedings do |t|
      t.references :legal_aid_application
      t.references :proceeding
      t.timestamps
    end
  end
end
