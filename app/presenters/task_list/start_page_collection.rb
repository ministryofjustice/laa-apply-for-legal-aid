module TaskList
  class StartPageCollection < Collection
    NEW_RECORD = "00000000-0000-0000-0000-000000000000".freeze

    # Template:
    #
    # SECTIONS = {
    #   task_list_section: {
    #    task_list_item_1 (name after step): displayed?,
    #    task_list_item_2 (name after step): displayed?,
    #    ....
    #   }
    # }
    #
    # Rules: name task list items after the [first] step in its flow.
    #
    # e.g.
    #  - Steps::ProviderStart::ApplicantsStep --> applicants
    #  - Steps::ProviderStart::AboutFinancialMeansStep --> about_financial_means
    #

    SECTIONS = {
      client_and_case_details: {
        applicants: true, # Steps::ProviderStart::ApplicantsStep
        # links_to_another: true, # TODO
        proceedings_types: true, # Steps::ProviderStart::ProceedingsTypesStep,
        check_provider_answers: true, # Steps::ProviderStart::CheckProviderAnswersStep
        check_benefits: true, # Steps::ProviderStart::CheckBenefitsStep
        # ^^ DWP Result check - THIS SECTION IS CONDITIONAL. it should perhaps not exist as depending on answers to previous
        # questions it would be different AND if answers change (*such as age) it would need to change the forward path
        # and even remove/soft-delete/discard existing data (e.g. means test answers).
        # [
        #   "check_benefits", # Steps::ProviderStart::CheckBenefitsStep
        #   "confirm_non_means_tested_application", # Steps::ProviderStart::ConfirmNonMeansTestedApplicationStep
        #   "no_national_insurance_numbers", # Steps::ProviderStart::NoNationalInsuranceNumbersStep
        # ],
      },

      means_assessment: {
        # Applicable for non-passported journeys only
        about_financial_means: ->(application) { application.non_passported? }, # Steps::ProviderStart::AboutFinancialMeansStep, # Income assessment # Only applicable for non-passported applications
        check_income_answers: ->(application) { application.non_passported? }, # Steps::ProviderIncome::CheckIncomeAnswersStep,"

        # Applicable for passported and non-passported journeys but not non-means-tested?!
        capital_introductions: ->(application) { application.passported? || application.non_passported? }, #  Steps::ProviderCapital::IntroductionsStep, # Capital assessment

        # capital CYA applicable for passported journeys
        check_passported_answers: ->(application) { application.passported? }, # Steps::ProviderCapital::CheckPassportedAnswersStep,

        # # capital CYA applicable for non-passported journeys
        check_capital_answers: ->(application) { application.non_passported? }, # Steps::ProviderCapital::CheckCapitalAnswersStep,

        # Passported means assessment result from CFE
        # capital_assessment_results: ->(application) { application.passported? }, # Steps::ProviderCapital::CapitalAssessmentResultsStep,

        # Non-passported means assessment result from CFE
        # capital_income_assessment_results: ->(application) { application.non_passported? }, # Steps::ProviderCapital::CapitalIncomeAssessmentResultsStep },
      },
    }.freeze
  end
end

# §1 Is conditional on if delegated functions used
# §2 Is conditional on if NOT a substantive application
# §3 Is where truelayer path splits
