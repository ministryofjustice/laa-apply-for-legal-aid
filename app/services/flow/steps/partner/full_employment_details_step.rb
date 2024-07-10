module Flow
  module Steps
    module Partner
      FullEmploymentDetailsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_full_employment_details_path(application) },
        forward: :partner_receives_state_benefits,
        check_answers: :check_income_answers,
      )
    end
  end
end
