class AddDelegatedFunctionsDateToApplicationProceedingTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :application_proceeding_types, :used_delegated_functions_on, :date
    add_column :application_proceeding_types, :used_delegated_functions_reported_on, :date
  end
end
