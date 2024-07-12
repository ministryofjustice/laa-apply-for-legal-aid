module Flow
  module Steps
    module ProviderIncome
      HousingBenefitsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_housing_benefits_path(application) },
        forward: :has_dependants,
        check_answers: :check_income_answers,
      )
    end
  end
end
