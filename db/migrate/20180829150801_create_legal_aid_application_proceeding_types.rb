class CreateLegalAidApplicationProceedingTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :application_proceeding_types, id: :uuid do |t|
      t.references :legal_aid_application
      t.references :proceeding_type
      t.timestamps
    end
  end
end
