module Flow
  module Steps
    module Partner
      UnexpectedEmploymentIncomeStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_unexpected_employment_income_path(application) },
        forward: :partner_receives_state_benefits,
      )
    end
  end
end
