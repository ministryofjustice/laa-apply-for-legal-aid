module Flow
  module Steps
    module Partner
      AboutFinancialMeansStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_about_financial_means_path(application) },
        forward: :partner_employed,
      )
    end
  end
end
