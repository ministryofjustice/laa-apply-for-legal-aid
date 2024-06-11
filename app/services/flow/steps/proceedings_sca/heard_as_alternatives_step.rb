module Flow
  module Steps
    module ProceedingsSCA
      HeardAsAlternativesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_heard_as_alternatives_path(application) },
        forward: :has_other_proceedings,
      )
    end
  end
end
