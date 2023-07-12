module Flow
  module Flows
    class ProviderPartner < FlowSteps
      STEPS = {
        client_has_partners: {
          path: ->(application) { urls.providers_legal_aid_application_client_has_partner_path(application) },
          forward: lambda do |_application, options|
            if options[:has_partner]
              :partner_details
            else
              :check_provider_answers
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
        partner_bank_statements: {
          path: ->(application) { urls.providers_legal_aid_application_partners_bank_statements_path(application) },
          forward: :has_dependants,
        },
        partner_use_ccms_employment: {
          path: ->(application) { urls.providers_legal_aid_application_partners_use_ccms_employment_index_path(application) },
        },
        partner_full_employment_details: {
          path: ->(application) { urls.providers_legal_aid_application_partners_full_employment_details_path(application) },
          forward: :has_dependants,
          check_answers: :check_provider_answers,
        },
      }.freeze
    end
  end
end
