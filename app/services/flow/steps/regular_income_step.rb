module Flow
  module Steps
    RegularIncomeStep = Step.new(
      ->(application) { urls.providers_legal_aid_application_means_regular_incomes_path(application) },
      ->(application) { application.income_types? ? :cash_incomes : :student_finances },
      ->(application) { application.income_types? ? :cash_incomes : :means_summaries },
    )
  end
end
