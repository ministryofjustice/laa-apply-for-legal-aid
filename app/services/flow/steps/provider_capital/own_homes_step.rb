module Flow
  module Steps
    module ProviderCapital
      OwnHomesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_own_home_path(application) },
        forward: lambda do |application|
          if application.own_home_no?
            application.vehicles.any? ? :add_other_vehicles : :vehicles
          else
            :property_details
          end
        end,
        carry_on_sub_flow: ->(application) { !application.own_home_no? },
        check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
