namespace :move_delegated_functions_data do
  desc 'Sets the lead_proceeding value to TRUE for all existing cases'

  task update_application_proceeding_type_table: :environment do
    # if delegated functions exist on the legal aid application
    # then move the values for used_delegated_functions_on AND used_delegated_functions_reported_on
    # to their respective fields on application_proceeding_types
  end
end
