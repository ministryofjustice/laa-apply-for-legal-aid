module Flow
  module Steps
    module ProviderStart
      AboutTheFinancialAssessmentsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_about_the_financial_assessment_path(application) },
        forward: :application_confirmations,
      )
    end
  end
end
