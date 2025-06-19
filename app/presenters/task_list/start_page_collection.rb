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
    #    subsections: {
    #      subsection_name: {
    #        sub_task_list_item_1 (name after step): displayed?
    #      }
    #    }
    #   }
    # }
    #
    # Rules: name task list items after the [first] step in its flow.
    #
    # e.g.
    #  - Steps::ProviderStart::ApplicantsStep --> applicants
    #  - Steps::ProviderStart::AboutFinancialMeansStep --> about_financial_means
    #
    # Body overide:
    #
    # If the section's task list cannot be shown and requires text to be displayed instead then the
    # body_override task key should be added. It's lambda should return the message to be displayed
    # only if it needs to be displayed. This will override displaying of the tasks for that section
    # replacing the tasks with the message body provided.
    #
    # e.g. body_override: ->(application) { "Not available yet because..." unless application.client_and_case_details_completed? },
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
        body_override: lambda { |application|
          "We may ask you later about your client's income, outgoings, savings, investments, assets, payments and dependants, if it's needed." unless TaskStatus::CheckBenefits.new(application).call.completed?
        },

        subsections: {
          financial_information: {
            # Applicable for non-passported journeys only
            about_financial_means: ->(application) { application.non_passported? }, # Steps::ProviderStart::AboutFinancialMeansStep, # Income assessment # Only applicable for non-passported applications
            check_income_answers: ->(application) { application.non_passported? }, # Steps::ProviderIncome::CheckIncomeAnswersStep,"
          },
          capital_and_assets: {
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
        },
      },
      merits_assessment: {
        body_override: ->(application) { "Once the proceedings have been selected, the relevant tasks will appear in this section." unless TaskStatus::CheckBenefits.new(application).call.completed? },
      },
      confirm_and_submit: {
        confirm_client_declarations: true, # Steps::ProviderMerits::ConfirmClientDeclarationsStep
      },
    }.freeze
  end
end

# §1 Is conditional on if delegated functions used
# §2 Is conditional on if NOT a substantive application
# §3 Is where truelayer path splits
