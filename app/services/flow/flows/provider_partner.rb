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
              :shared_addresses
            end
          end,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: false,
        },
        shared_addresses: {
          path: ->(application) { urls.providers_legal_aid_application_shared_address_path(application) },
          forward: lambda do |_application, options|
            if options[:shared_address]
              :check_provider_answers
            else
              :partner_address_lookups
            end
          end,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: ->(application) { !application&.partner&.shared_address_with_client? },
        },
        partner_address_lookups: {
          path: ->(application) { urls.providers_legal_aid_application_partners_address_lookup_path(application) },
          forward: :partner_address_selections,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: true,
        },
        partner_address_selections: {
          path: ->(application) { urls.providers_legal_aid_application_partners_address_selection_path(application) },
          forward: :check_provider_answers,
          check_answers: :check_provider_answers,
        },
        partner_addresses: {
          path: ->(application) { urls.providers_legal_aid_application_partners_address_path(application) },
          forward: :check_provider_answers,
          check_answers: :check_provider_answers,
        },
        partner_employed: {
          path: ->(application) { urls.providers_legal_aid_application_partners_employed_index_path(application) },
          forward: lambda do |application|
            if application.partner.self_employed? || application.partner.armed_forces?
              :partner_use_ccms_employed
            elsif application.partner.employed? && !application.partner.has_national_insurance_number?
              :partner_full_employment_details
            else
              :has_dependants
            end
          end,
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
