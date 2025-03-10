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
        ],
      ],
    ].freeze
  end
end
