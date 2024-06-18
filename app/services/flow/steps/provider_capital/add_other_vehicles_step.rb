module Flow
  module Steps
    module ProviderCapital
      AddOtherVehiclesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_add_other_vehicles_path(application) },
        forward: lambda do |application, add_other_vehicles|
          if add_other_vehicles
            :vehicle_details
          elsif application.non_passported? && !application.uploading_bank_statements?
            :applicant_bank_accounts
          else
            :offline_accounts
          end
        end,
        check_answers: lambda do |application, add_other_vehicles|
          if add_other_vehicles
            :vehicle_details
          else
            application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers
          end
        end,
      )
    end
  end
end
