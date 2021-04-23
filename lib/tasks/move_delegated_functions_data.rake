namespace :move_delegated_functions_data do
  desc 'Copies over used delegated functions data from legal aid application to application proceeding type'

  task update_application_proceeding_type_table: :environment do
    # if delegated functions exist on the legal aid application
    # then move the values for used_delegated_functions_on AND used_delegated_functions_reported_on
    # to their respective fields on application_proceeding_types
    application_ids = LegalAidApplication.where.not(used_delegated_functions_on: nil).pluck(:id)

    application_ids.each do |ap_id|
      application = LegalAidApplication.find(ap_id)

      application.application_proceeding_types.each do |apt|
        apt.used_delegated_functions_on = application.used_delegated_functions_on
        apt.used_delegated_functions_reported_on = application.used_delegated_functions_reported_on

        apt.save!
      end
    end
  end
end
