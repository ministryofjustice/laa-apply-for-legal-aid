module Flow
  module Steps
    module ProviderCapital
      VehicleDetailsStep = Step.new(
        path: ->(application) { Steps.urls.new_providers_legal_aid_application_means_vehicle_detail_path(application) },
        forward: :add_other_vehicles,
        check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
