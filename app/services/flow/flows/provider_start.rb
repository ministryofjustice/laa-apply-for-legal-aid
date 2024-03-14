module Flow
  module Flows
    class ProviderStart < FlowSteps
      STEPS = {
        providers_home: {
          path: ->(_application) { urls.providers_legal_aid_applications_path },
        },
        applicants: {
          path: ->(_) { urls.new_providers_applicant_path },
          forward: :address_lookups,
        },
        applicant_details: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_details_path(application) },
          forward: lambda do |application|
            if application.overriding_dwp_result?
              :has_national_insurance_numbers
            else
              :address_lookups
            end
          end,
          check_answers: :check_provider_answers,
        },
        address_lookups: {
          path: ->(application) { urls.providers_legal_aid_application_address_lookup_path(application) },
          forward: :address_selections,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: true,
        },
        address_selections: {
          path: ->(application) { urls.providers_legal_aid_application_address_selection_path(application) },
          forward: lambda do |application|
            if Setting.home_address?
              :different_addresses
            elsif Setting.linked_applications?
              :copy_case_invitations
            else
              application.proceedings.any? ? :has_other_proceedings : :proceedings_types
            end
          end,
          check_answers: :check_provider_answers,
        },
        home_address_lookups: {
          path: ->(application) { urls.providers_legal_aid_application_home_address_home_address_lookup_path(application) },
          forward: :home_address_selections,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: true,
        },
        home_address_selections: {
          path: ->(application) { urls.providers_legal_aid_application_home_address_home_address_selection_path(application) },
          forward: lambda do |application|
            if Setting.linked_applications?
              :copy_case_invitations
            else
              application.proceedings.any? ? :has_other_proceedings : :proceedings_types
            end
          end,
          check_answers: :check_provider_answers,
        },
        addresses: {
          path: ->(application) { urls.providers_legal_aid_application_address_path(application) },
          forward: lambda do |application|
            if Setting.linked_applications?
              :copy_case_invitations
            else
              application.proceedings.any? ? :has_other_proceedings : :proceedings_types
            end
          end,
          check_answers: :check_provider_answers,
        },
        different_addresses: {
          path: ->(application) { urls.providers_legal_aid_application_home_address_different_address_path(application) },
          forward: lambda do |application|
            if application.applicant.same_correspondence_and_home_address?
              application.proceedings.any? ? :has_other_proceedings : :proceedings_types
            else
              :different_address_reasons
            end
          end,
        },
        different_address_reasons: {
          path: ->(application) { urls.providers_legal_aid_application_home_address_different_address_reason_path(application) },
          forward: lambda do |application|
            if application.applicant.no_fixed_residence?
              application.proceedings.any? ? :has_other_proceedings : :proceedings_types
            else
              :home_address_lookups
            end
          end,
        },
        non_uk_correspondence_addresses: {
          path: ->(application) { urls.providers_legal_aid_application_non_uk_correspondence_address_path(application) },
          forward: lambda do |application|
            if Setting.linked_applications?
              :copy_case_invitations
            else
              application.proceedings.any? ? :has_other_proceedings : :proceedings_types
            end
          end,
          check_answers: :check_provider_answers,
        },
        copy_case_invitations: {
          path: ->(application) { urls.providers_legal_aid_application_copy_case_invitation_path(application) },
          forward: lambda do |application|
            if application.copy_case?
              :copy_case_searches
            else
              :link_case_invitations
            end
          end,
          check_answers: :check_provider_answers,
        },
        copy_case_searches: {
          path: ->(application) { urls.providers_legal_aid_application_copy_case_search_path(application) },
          forward: :copy_case_confirmations,
          check_answers: :check_provider_answers,
        },
        copy_case_confirmations: {
          path: ->(application) { urls.providers_legal_aid_application_copy_case_confirmation_path(application) },
          forward: lambda do |_application, options|
            options[:copy_case_confirmed] ? :link_case_confirmations : :copy_case_invitations
          end,
          check_answers: :check_provider_answers,
        },
        link_case_invitations: {
          path: ->(application) { urls.providers_legal_aid_application_link_case_invitation_path(application) },
          forward: lambda do |application|
            if application.link_case?
              :link_case_searches
            else
              application.proceedings.any? ? :has_other_proceedings : :proceedings_types
            end
          end,
        },
        link_case_searches: {
          path: ->(application) { urls.providers_legal_aid_application_link_case_search_path(application) },
          forward: :link_case_confirmations,
        },
        link_case_confirmations: {
          path: ->(application) { urls.providers_legal_aid_application_link_case_confirmation_path(application) },
          forward: lambda do |_application, options|
            options[:link_case_confirmed] ? :has_national_insurance_numbers : :link_case_invitations
          end,
        },
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
        delete: {
          path: ->(application) { urls.providers_legal_aid_application_delete_path(application) },
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
