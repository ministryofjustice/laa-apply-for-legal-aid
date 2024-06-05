module Flow
  module Steps
    module ProviderMerits
      DateClientToldIncidentsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_date_client_told_incident_path(application) },
        forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
        check_answers: :check_merits_answers,
      )
    end
  end
end
