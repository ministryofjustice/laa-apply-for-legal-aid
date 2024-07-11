module Flow
  module Steps
    module Partner
      CashIncomesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_cash_income_path(application) },
        forward: :partner_student_finances,
        check_answers: :check_income_answers,
      )
    end
  end
end
