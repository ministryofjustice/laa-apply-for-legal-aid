class RemoveCcmsReferenceNumberFromApplications < ActiveRecord::Migration[5.2]
  def up
    remove_column :legal_aid_applications, :ccms_reference_number
  end

  def down
    add_column :legal_aid_applications, :ccms_reference_number, :string
  end
end
