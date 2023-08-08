module Flow
  module Flows
    class ProviderPartner < FlowSteps
      STEPS = {
        client_has_partners: {
          path: ->(application) { urls.providers_legal_aid_application_client_has_partner_path(application) },
          forward: lambda do |_application, options|
            if options[:has_partner]
              :contrary_interests
            else
              :check_provider_answers
            end
          end,
        },
        contrary_interests: {
          path: ->(application) { urls.providers_legal_aid_application_contrary_interest_path(application) },
          forward: lambda do |_application, options|
            if options[:partner_has_contrary_interest]
              :check_provider_answers
            else
              :partner_details
            end
          end,
        },
        partner_details: {
          path: ->(application) { urls.providers_legal_aid_application_partners_details_path(application) },
          forward: lambda do |application|
            if application.overriding_dwp_result?
              :check_client_details
            else
              :check_provider_answers
            end
          end,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: false,
        },
        partner_employed: {
          path: ->(application) { urls.providers_legal_aid_application_partners_employed_index_path(application) },
          forward: lambda do |application|
            if application.partner.self_employed? || application.partner.armed_forces?
              :partner_use_ccms_employment
            elsif application.partner.employed? && !application.partner.has_national_insurance_number?
              :partner_full_employment_details
            else
              :partner_bank_statements
            end
          end,
        },
        partner_use_ccms_employment: {
          path: ->(application) { urls.providers_legal_aid_application_partners_use_ccms_employment_index_path(application) },
        },
        partner_bank_statements: {
          path: ->(application) { urls.providers_legal_aid_application_partners_bank_statements_path(application) },
          forward: lambda do |application|
            status = HMRC::PartnerStatusAnalyzer.call(application)
            case status
            when :partner_multiple_employments, :partner_no_hmrc_data
              :partner_full_employment_details
            when :partner_single_employment
              :partner_employment_income
            when :partner_unexpected_employment_data
              :partner_unexpected_employment_incomes
            when :partner_not_employed
              :partner_receives_state_benefits
            else
              raise "Unexpected hmrc status #{status.inspect}"
            end
          end,
        },
        partner_receives_state_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_partners_receives_state_benefits_path(application) },
          forward: lambda do |_application, receives_state_benefits|
            receives_state_benefits ? :partner_state_benefits : :partner_student_finances
          end,
        },
        partner_state_benefits: {
          path: ->(application) { urls.new_providers_legal_aid_application_partners_state_benefit_path(application) },
          forward: :partner_add_other_state_benefits,
        },
        partner_add_other_state_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_partners_add_other_state_benefits_path(application) },
          forward: lambda do |_application, add_other_state_benefits|
            add_other_state_benefits ? :partner_state_benefits : :partner_student_finances
          end,
        },
        partner_remove_state_benefits: {
          forward: lambda do |_application, partner_has_any_state_benefits|
            partner_has_any_state_benefits ? :partner_add_other_state_benefits : :partner_receives_state_benefits
          end,
        },
        partner_student_finances: {
          path: ->(application) { urls.providers_legal_aid_application_partners_student_finance_path(application) },
          forward: :has_dependants,
        },
        partner_full_employment_details: {
          path: ->(application) { urls.providers_legal_aid_application_partners_full_employment_details_path(application) },
          forward: :partner_receives_state_benefits,
          check_answers: :check_provider_answers,
        },
        partner_employment_income: {
          path: ->(application) { urls.providers_legal_aid_application_partners_employment_income_path(application) },
          forward: :partner_receives_state_benefits,
        },
        partner_unexpected_employment_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_partners_unexpected_employment_income_path(application) },
          forward: :partner_receives_state_benefits,
        },
      }.freeze
    end
  end
end
