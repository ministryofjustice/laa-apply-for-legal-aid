class CreateLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :legal_aid_applications, id: :uuid do |t|
      t.string :application_ref

      t.timestamps
    end
  end
end
