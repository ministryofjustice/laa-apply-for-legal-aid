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
          # ^^ THIS SECTION IS CONDITIONAL. it should perhaps not exist as depending on answers to previous
          # questions it would be different AND if answers change (*such as age) it would need to change the forward path
          # and even remove/soft-delete/discard existing data (e.g. means test answers).
          # [
          #   "check_benefits", # Steps::ProviderStart::CheckBenefitsStep
          #   "confirm_non_means_tested_application", # Steps::ProviderStart::ConfirmNonMeansTestedApplicationStep
          #   "no_national_insurance_numbers", # Steps::ProviderStart::NoNationalInsuranceNumbersStep
          # ],
        ],
      ],
    ].freeze
  end
end
