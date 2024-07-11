module Flow
  module Steps
    module Partner
      RegularIncomesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_regular_incomes_path(application) },
        forward: lambda do |application|
          application.partner_income_types? ? :partner_cash_incomes : :partner_student_finances
        end,
        check_answers: ->(application) { application.partner_income_types? ? :partner_cash_incomes : :check_income_answers },
      )
    end
  end
end
