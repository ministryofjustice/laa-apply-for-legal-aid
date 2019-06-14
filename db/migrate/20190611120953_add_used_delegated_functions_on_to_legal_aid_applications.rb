class AddUsedDelegatedFunctionsOnToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :used_delegated_functions_on, :date
    add_column :legal_aid_applications, :used_delegated_functions, :boolean
  end
end
