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
        partner_about_financial_means: {
          path: ->(application) { urls.providers_legal_aid_application_partners_about_financial_means_path(application) },
          forward: :partner_employed,
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
            receives_state_benefits ? :partner_state_benefits : :partner_regular_incomes
          end,
        },
        partner_state_benefits: {
          path: ->(application) { urls.new_providers_legal_aid_application_partners_state_benefit_path(application) },
          forward: :partner_add_other_state_benefits,
        },
        partner_add_other_state_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_partners_add_other_state_benefits_path(application) },
          forward: lambda do |_application, add_other_state_benefits|
            add_other_state_benefits ? :partner_state_benefits : :partner_regular_incomes
          end,
        },
        partner_remove_state_benefits: {
          forward: lambda do |_application, partner_has_any_state_benefits|
            partner_has_any_state_benefits ? :partner_add_other_state_benefits : :partner_receives_state_benefits
          end,
        },
        partner_regular_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_partners_regular_incomes_path(application) },
          forward: lambda do |application|
            application.partner_income_types? ? :partner_cash_incomes : :partner_student_finances
          end,
          check_answers: ->(application) { application.partner_income_types? ? :partner_cash_incomes : :check_income_answers },
        },
        partner_cash_incomes: {
          path: ->(application) { urls.providers_legal_aid_application_partners_cash_income_path(application) },
          forward: :partner_student_finances,
          check_answers: ->(application) { application.uploading_bank_statements? ? :check_income_answers : :income_summary },
        },
        partner_student_finances: {
          path: ->(application) { urls.providers_legal_aid_application_partners_student_finance_path(application) },
          forward: :partner_regular_outgoings,
        },
        partner_regular_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_partners_regular_outgoings_path(application) },
          forward: lambda do |application|
            if application.partner_outgoing_types?
              :partner_cash_outgoings
            else
              :has_dependants
            end
          end,
          # to be added when CYA page is added
          #
          # check_answers: lambda do |application|
          #   if application.partner.housing_payments?
          #     :housing_benefits
          #   elsif application.partner_outgoing_types?
          #     :cash_outgoings
          #   else
          #     :check_income_answers
          #   end
          # end,
        },
        partner_cash_outgoings: {
          path: ->(application) { urls.providers_legal_aid_application_partners_cash_outgoing_path(application) },
          forward: lambda do |application|
            # if the applicant did not use Truelayer and makes housing payments, or if the partner makes housing payments, then ask about housing benefit
            if (application.housing_payments_for?("Applicant") && application.uploading_bank_statements?) || application.housing_payments_for?("Partner")
              :housing_benefits
            else
              :has_dependants
            end
          end,
          # to be added when CYA page is added
          #
          # check_answers: ->(application) { application.uploading_bank_statements? ? :check_income_answers : :outgoings_summary },
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
