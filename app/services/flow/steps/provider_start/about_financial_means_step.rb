module Flow
  module Steps
    module ProviderStart
      AboutFinancialMeansStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_about_financial_means_path(application) },
        forward: :applicant_employed,
      )
    end
  end
end
