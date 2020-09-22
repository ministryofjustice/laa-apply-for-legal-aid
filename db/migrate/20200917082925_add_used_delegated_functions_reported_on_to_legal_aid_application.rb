class AddUsedDelegatedFunctionsReportedOnToLegalAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :legal_aid_applications, :used_delegated_functions_reported_on, :date
  end
end
