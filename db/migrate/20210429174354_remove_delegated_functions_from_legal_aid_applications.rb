class RemoveDelegatedFunctionsFromLegalAidApplications < ActiveRecord::Migration[6.1]
  def change
    remove_column :legal_aid_applications, :used_delegated_functions, :boolean
    remove_column :legal_aid_applications, :used_delegated_functions_on, :date
    remove_column :legal_aid_applications, :used_delegated_functions_reported_on, :date
  end
end
