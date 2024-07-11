module Flow
  module Steps
    module Partner
      StudentFinancesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_student_finance_path(application) },
        forward: :partner_regular_outgoings,
        check_answers: :check_income_answers,
      )
    end
  end
end
