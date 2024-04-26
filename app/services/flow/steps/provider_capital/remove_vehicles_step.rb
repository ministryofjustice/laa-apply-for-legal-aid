module Flow
  module Steps
    module ProviderCapital
      RemoveVehiclesStep = Step.new(
        path: ->(application, vehicle) { Steps.urls.providers_legal_aid_application_means_remove_vehicle_path(application, vehicle) },
        forward: lambda do |_application, applicant_has_any_vehicles|
          if applicant_has_any_vehicles
            :add_other_vehicles
          else
            :vehicles
          end
        end,
      )
    end
  end
end
