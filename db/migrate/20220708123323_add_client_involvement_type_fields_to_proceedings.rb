class AddClientInvolvementTypeFieldsToProceedings < ActiveRecord::Migration[7.0]
  def up
    # create the columns as nullable
    change_table :proceedings, bulk: true do |t|
      t.string :client_involvement_type_ccms_code, null: true
      t.string :client_involvement_type_description, null: true
    end
    # Set default values for existing records
    Proceeding.where(client_involvement_type_ccms_code: nil).update_all(client_involvement_type_ccms_code: "A",
                                                                        client_involvement_type_description: "Applicant/claimant/petitioner")
  end

  def down
    change_table :proceedings, bulk: true do |t|
      t.remove :client_involvement_type_ccms_code, :client_involvement_type_description
    end
  end
end
