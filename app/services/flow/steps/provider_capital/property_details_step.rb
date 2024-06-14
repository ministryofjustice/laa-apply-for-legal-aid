module Flow
  module Steps
    module ProviderCapital
      PropertyDetailsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_property_details_path(application) },
        forward: :vehicles,
        check_answers: :restrictions,
      )
    end
  end
end
