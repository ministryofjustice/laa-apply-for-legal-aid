module Flow
  module Flows
    class ProviderStart < FlowSteps
      STEPS = {
        providers_home: Steps::ProvidersHomeStep,
        delete: Steps::DeleteStep,
        applicants: Steps::ProviderStart::ApplicantsStep,
        applicant_details: Steps::ProviderStart::ApplicantDetailsStep,
        correspondence_address_choices: Steps::Addresses::CorrespondenceAddressChoicesStep,
        correspondence_address_lookups: Steps::Addresses::CorrespondenceAddressLookupsStep,
        correspondence_address_selections: Steps::Addresses::CorrespondenceAddressSelectionsStep,
        correspondence_address_manuals: Steps::Addresses::CorrespondenceAddressManualsStep,
        correspondence_address_care_ofs: Steps::Addresses::CorrespondenceAddressCareOfsStep,
        home_address_statuses: Steps::Addresses::HomeAddressStatusesStep,
        home_address_lookups: Steps::Addresses::HomeAddressLookupsStep,
        home_address_selections: Steps::Addresses::HomeAddressSelectionsStep,
        home_address_manuals: Steps::Addresses::HomeAddressManualsStep,
        non_uk_home_addresses: Steps::Addresses::NonUkHomeAddressesStep,
        link_application_make_links: Steps::LinkedApplications::MakeLinkStep,
        link_application_find_link_applications: Steps::LinkedApplications::FindLinkStep,
        link_application_confirm_links: Steps::LinkedApplications::ConfirmLinkStep,
        link_application_copies: Steps::LinkedApplications::CopyStep,
        about_financial_means: {
          path: ->(application) { urls.providers_legal_aid_application_about_financial_means_path(application) },
          forward: :applicant_employed,
        },
        applicant_employed: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_employed_index_path(application) },
          forward: lambda do |application|
            next_step = application.used_delegated_functions? ? :substantive_applications : :open_banking_consents

            application.employment_journey_ineligible? ? :use_ccms_employment : next_step
          end,
        },
        proceedings_types: Steps::ProviderStart::ProceedingsTypesStep,
        proceedings_sca_proceeding_issue_statuses: Steps::ProceedingsSCA::ProceedingIssueStatusesStep,
        proceedings_sca_supervision_orders: Steps::ProceedingsSCA::SupervisionOrderStep,
        proceedings_sca_child_subjects: Steps::ProceedingsSCA::ChildSubjectsStep,
        proceedings_sca_heard_togethers: Steps::ProceedingsSCA::HeardTogethersStep,
        proceedings_sca_heard_as_alternatives: Steps::ProceedingsSCA::HeardAsAlternativesStep,
        proceedings_sca_change_of_names: Steps::ProceedingsSCA::ChangeOfNamesStep,
        has_other_proceedings: Steps::ProviderStart::HasOtherProceedingsStep,
        limitations: Steps::ProviderStart::LimitationsStep,
        has_national_insurance_numbers: {
          path: ->(application) { urls.providers_legal_aid_application_has_national_insurance_number_path(application) },
          forward: lambda do |application|
            if application.overriding_dwp_result?
              :check_provider_answers
            else
              :client_has_partners
            end
          end,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: false,
        },
        # partner_flow called here
        check_provider_answers: Steps::ProviderStart::CheckProviderAnswersStep,
        confirm_non_means_tested_applications: Steps::ProviderStart::ConfirmNonMeansTestedApplicationStep,
        no_national_insurance_numbers: Steps::ProviderStart::NoNationalInsuranceNumbersStep,
        check_benefits: Steps::ProviderStart::CheckBenefitsStep,
        substantive_applications: Steps::ProviderStart::SubstantiveApplicationsStep,
        delegated_confirmation: {
          path: ->(application) { urls.providers_legal_aid_application_delegated_confirmation_index_path(application) },
        },
        open_banking_consents: Steps::ProviderStart::OpenBankingConsentsStep,
        open_banking_guidances: Steps::ProviderStart::OpenBankingGuidancesStep,
        bank_statements: Steps::ProviderStart::BankStatementsStep,
        # provider_means_state_benefits is called here
        email_addresses: Steps::ProviderStart::EmailAddressesStep,
        about_the_financial_assessments: {
          path: ->(application) { urls.providers_legal_aid_application_about_the_financial_assessment_path(application) },
          forward: :application_confirmations,
        },
        application_confirmations: Steps::ProviderStart::ApplicationConfirmationsStep,
        use_ccms: Steps::ProviderStart::UseCCMSStep,
        use_ccms_employment: Steps::ProviderStart::UseCCMSEmploymentStep,
        use_ccms_under16s: Steps::ProviderStart::UseCCMSUnder16sStep,
      }.freeze
    end
  end
end
