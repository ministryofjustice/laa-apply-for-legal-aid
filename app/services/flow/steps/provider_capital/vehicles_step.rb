module Flow
  module Steps
    module ProviderCapital
      VehiclesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_vehicle_path(application) },
        forward: lambda do |application|
          if application.own_vehicle?
            :vehicle_details
          elsif application.non_passported? && !application.uploading_bank_statements?
            :applicant_bank_accounts
          else
            :offline_accounts
          end
        end,
        carry_on_sub_flow: ->(application) { application.own_vehicle? },
        check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
