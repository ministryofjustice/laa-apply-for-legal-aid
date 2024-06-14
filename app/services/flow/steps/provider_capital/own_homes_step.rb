module Flow
  module Steps
    module ProviderCapital
      OwnHomesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_own_home_path(application) },
        forward: ->(application) { application.own_home_no? ? :vehicles : :property_details },
        carry_on_sub_flow: ->(application) { !application.own_home_no? },
        check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
