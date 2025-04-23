module TaskList
  class StartPageCollection < Collection
    NEW_RECORD = "00000000-0000-0000-0000-000000000000".freeze

    SECTIONS = [
      [
        "client_details",
        [
          "applicants", # Steps::ProviderStart::ApplicantsStep
        ],
      ],
      [
        "about_the_case",
        [
          "proceedings_types", # Steps::ProviderStart::ProceedingsTypesStep,
          "has_national_insurance_numbers", # Steps::ProviderStart::HasNationalInsuranceNumbersStep
          "check_provider_answers", # Steps::ProviderStart::CheckProviderAnswersStep
          "check_benefits", # Steps::ProviderStart::CheckBenefitsStep
          # ^^ DWP Result check - THIS SECTION IS CONDITIONAL. it should perhaps not exist as depending on answers to previous
          # questions it would be different AND if answers change (*such as age) it would need to change the forward path
          # and even remove/soft-delete/discard existing data (e.g. means test answers).
          # [
          #   "check_benefits", # Steps::ProviderStart::CheckBenefitsStep
          #   "confirm_non_means_tested_application", # Steps::ProviderStart::ConfirmNonMeansTestedApplicationStep
          #   "no_national_insurance_numbers", # Steps::ProviderStart::NoNationalInsuranceNumbersStep
          # ],
        ],
      ],
      [
        "means_assessment",
        [
          # Applicable for non-passported journeys only
          "about_financial_means", # Steps::ProviderStart::AboutFinancialMeansStep, # Income assessment # Only applicable for non-passported applications
          "check_income_answers", # Steps::ProviderIncome::CheckIncomeAnswersStep,"

          # Applicable for passported and non-passported journeys but not non-means-tested?!
          "capital_introductions", #  Steps::ProviderCapital::IntroductionsStep, # Capital assessment

          # capital CYA applicable for passported journeys
          "check_passported_answers", # Steps::ProviderCapital::CheckPassportedAnswersStep,

          # capital CYA applicable for non-passported journeys
          "check_capital_answers", # Steps::ProviderCapital::CheckCapitalAnswersStep,

          "capital_assessment_results", # Steps::ProviderCapital::CapitalAssessmentResultsStep, # Passported means assessment result from CFE

          "capital_income_assessment_results", # Steps::ProviderCapital::CapitalIncomeAssessmentResultsStep }, # Non-passported means assessment result from CFE
        ],
      ],
    ].freeze
  end
end

# §1 Is conditional on if delegated functions used
# §2 Is conditional on if NOT a substantive application
# §3 Is where truelayer path splits
