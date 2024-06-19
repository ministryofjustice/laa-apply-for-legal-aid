module Flow
  module Flows
    class ProviderPartner < FlowSteps
      STEPS = {
        client_has_partners: Steps::Partner::ClientHasPartnersStep,
        contrary_interests: Steps::Partner::ContraryInterestsStep,
        partner_details: Steps::Partner::DetailsStep,
        partner_about_financial_means: Steps::Partner::AboutFinancialMeansStep,
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
              :partner_employment_incomes
            when :partner_unexpected_employment_data
              :partner_unexpected_employment_incomes
            when :partner_not_employed
              :partner_receives_state_benefits
            else
              raise "Unexpected hmrc status #{status.inspect}"
            end
          end,
          check_answers: :check_income_answers,
        },
        partner_receives_state_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_partners_receives_state_benefits_path(application) },
          forward: lambda do |_application, receives_state_benefits|
            receives_state_benefits ? :partner_state_benefits : :partner_regular_incomes
          end,
          check_answers: lambda do |application|
            if application.partner.receives_state_benefits?
              if application.partner.state_benefits.count.positive?
                :partner_add_other_state_benefits
              else
                :partner_state_benefits
              end
            else
              :check_income_answers
            end
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
          check_answers: lambda do |_application, add_other_state_benefits|
            add_other_state_benefits ? :partner_state_benefits : :check_income_answers
          end,
        },
        partner_remove_state_benefits: Steps::Partner::RemoveStateBenefitsStep,
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
          check_answers: :check_income_answers,
        },
        partner_student_finances: {
          path: ->(application) { urls.providers_legal_aid_application_partners_student_finance_path(application) },
          forward: :partner_regular_outgoings,
          check_answers: :check_income_answers,
        },
        partner_regular_outgoings: Steps::Partner::RegularOutgoingsStep,
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
          check_answers: lambda do |application|
            if (application.housing_payments_for?("Applicant") && application.uploading_bank_statements?) || application.housing_payments_for?("Partner")
              :housing_benefits
            else
              :has_dependants
            end
          end,
        },
        partner_full_employment_details: {
          path: ->(application) { urls.providers_legal_aid_application_partners_full_employment_details_path(application) },
          forward: :partner_receives_state_benefits,
          check_answers: :check_income_answers,
        },
        partner_employment_incomes: {
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
