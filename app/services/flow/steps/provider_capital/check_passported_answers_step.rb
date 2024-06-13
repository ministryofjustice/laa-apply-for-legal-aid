module Flow
  module Steps
    module ProviderCapital
      CheckPassportedAnswersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_check_passported_answers_path(application) },
        forward: :capital_assessment_results,
      )
    end
  end
end
