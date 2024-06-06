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
        has_other_proceedings: Steps::ProviderStart::HasOtherProceedingsStep,
        limitations: Steps::ProviderStart::LimitationsStep,
        has_national_insurance_numbers: {
          path: ->(application) { urls.providers_legal_aid_application_has_national_insurance_number_path(application) },
          forward: lambda do |application|
            if Setting.partner_means_assessment? && !application.overriding_dwp_result?
              :client_has_partners
            else
              :check_provider_answers
            end
          end,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: false,
        },
        # partner_flow called here
        check_provider_answers: {
          path: ->(application) { urls.providers_legal_aid_application_check_provider_answers_path(application) },
          forward: lambda do |application|
            if application.under_16_blocked?
              :use_ccms_under16s
            elsif application.non_means_tested?
              application.change_state_machine_type("NonMeansTestedStateMachine")
              :confirm_non_means_tested_applications
            else
              application.applicant.national_insurance_number? ? :check_benefits : :no_national_insurance_numbers
            end
          end,
        },
        confirm_non_means_tested_applications: Steps::ProviderStart::ConfirmNonMeansTestedApplicationStep,
        no_national_insurance_numbers: {
          path: ->(application) { urls.providers_legal_aid_application_no_national_insurance_number_path(application) },
          forward: lambda do |application|
            application.change_state_machine_type("NonPassportedStateMachine")
            :applicant_employed
          end,
        },
        check_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_check_benefits_path(application) },
          forward: lambda do |application, dwp_override_non_passported|
            if application.applicant_receives_benefit?
              application.change_state_machine_type("PassportedStateMachine")
              application.used_delegated_functions? ? :substantive_applications : :capital_introductions
            else
              application.change_state_machine_type("NonPassportedStateMachine")
              dwp_override_non_passported ? :confirm_dwp_non_passported_applications : :applicant_employed
            end
          end,
        },
        substantive_applications: {
          path: ->(application) { urls.providers_legal_aid_application_substantive_application_path(application) },
          forward: lambda do |application|
            return :delegated_confirmation unless application.substantive_application?

            if application.applicant_receives_benefit?
              :capital_introductions
            else
              :open_banking_consents
            end
          end,
        },
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
        application_confirmations: {
          path: ->(application) { urls.providers_legal_aid_application_application_confirmation_path(application) },
        },
        use_ccms: {
          path: ->(application) { urls.providers_legal_aid_application_use_ccms_path(application) },
        },
        use_ccms_employment: {
          path: ->(application) { urls.providers_legal_aid_application_use_ccms_employment_index_path(application) },
        },
        use_ccms_under16s: {
          path: ->(application) { urls.providers_legal_aid_application_use_ccms_under16s_path(application) },
        },
      }.freeze
    end
  end
end
