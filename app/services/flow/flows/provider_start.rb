module Flow
  module Flows
    class ProviderStart < FlowSteps
      STEPS = {
        providers_home: Steps::ProvidersHomeStep,
        delete: Steps::DeleteStep,
        applicants: Steps::ProviderStart::ApplicantsStep,
        applicant_details: Steps::ProviderStart::ApplicantDetailsStep,
        correspondence_address_lookups: Steps::Addresses::CorrespondenceAddressLookupsStep,
        correspondence_address_selections: Steps::Addresses::CorrespondenceAddressSelectionsStep,
        correspondence_address_manuals: Steps::Addresses::CorrespondenceAddressManualsStep,
        different_addresses: Steps::Addresses::DifferentAddressesStep,
        different_address_reasons: Steps::Addresses::DifferentAddressReasonsStep,
        home_address_lookups: Steps::Addresses::HomeAddressLookupsStep,
        home_address_selections: Steps::Addresses::HomeAddressSelectionsStep,
        home_address_manuals: Steps::Addresses::HomeAddressManualsStep,
        non_uk_home_addresses: Steps::Addresses::NonUkHomeAddressesStep,
        link_application_make_links: Steps::LinkedApplications::MakeLinkStep,
        link_application_find_link_applications: {
          path: ->(application) { urls.providers_legal_aid_application_link_application_find_link_application_path(application) },
          forward: :link_application_confirm_links,
        },
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
        proceedings_types: {
          path: ->(application) { urls.providers_legal_aid_application_proceedings_types_path(application) },
          forward: :has_other_proceedings,
        },
        has_other_proceedings: {
          path: ->(application) { urls.providers_legal_aid_application_has_other_proceedings_path(application) },
          forward: lambda do |application, add_another_proceeding|
            if add_another_proceeding
              :proceedings_types
            else
              Flow::ProceedingLoop.next_step(application)
            end
          end,
        },
        limitations: {
          path: ->(application) { urls.providers_legal_aid_application_limitations_path(application) },
          forward: :has_national_insurance_numbers,
          check_answers: :check_provider_answers,
        },
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
        confirm_non_means_tested_applications: {
          path: ->(application) { urls.providers_legal_aid_application_confirm_non_means_tested_applications_path(application) },
          forward: :merits_task_lists,
        },
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
        open_banking_consents: {
          path: ->(application) { urls.providers_legal_aid_application_open_banking_consents_path(application) },
          forward: lambda do |application|
            application.provider_received_citizen_consent? ? :open_banking_guidances : :bank_statements
          end,
        },

        open_banking_guidances: {
          path: ->(application) { urls.providers_legal_aid_application_open_banking_guidance_path(application) },
          forward: lambda do |_application, client_can_use_truelayer|
            client_can_use_truelayer ? :email_addresses : :bank_statements
          end,
        },
        bank_statements: {
          path: ->(application) { urls.providers_legal_aid_application_bank_statements_path(application) },
          forward: lambda do |application|
            status = HMRC::StatusAnalyzer.call(application)
            case status
            when :applicant_multiple_employments, :applicant_no_hmrc_data
              :full_employment_details
            when :applicant_single_employment
              :employment_incomes
            when :applicant_unexpected_employment_data
              :unexpected_employment_incomes
            when :applicant_not_employed
              :receives_state_benefits
            else
              raise "Unexpected hmrc status #{status.inspect}"
            end
          end,
          check_answers: :check_income_answers,
        },
        # provider_means_state_benefits is called here
        email_addresses: {
          path: ->(application) { urls.providers_legal_aid_application_email_address_path(application) },
          forward: :about_the_financial_assessments,
        },
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
