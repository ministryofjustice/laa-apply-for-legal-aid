module Flow
  module Steps
    module ProviderCapital
      VehicleDetailsStep = Step.new(
        path: lambda do |application|
          if application.provider_step_params["id"]
            vehicle = application.vehicles.find(application.provider_step_params["id"])
            Steps.urls.providers_legal_aid_application_means_vehicle_detail_path(application, vehicle)
          else
            Steps.urls.new_providers_legal_aid_application_means_vehicle_detail_path(application)
          end
        end,
        forward: :add_other_vehicles,
        check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
