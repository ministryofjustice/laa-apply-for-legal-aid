module Flow
  module Flows
    class ProviderPartner < FlowSteps
      STEPS = {
        client_has_partners: {
          path: ->(application) { urls.providers_legal_aid_application_client_has_partner_path(application) },
          forward: lambda do |_application, options|
            if options[:has_partner]
              :details
            else
              :check_provider_answers
            end
          end,
        },
        details: {
          path: ->(application) { urls.providers_legal_aid_application_partners_details_path(application) },
          forward: :check_provider_answers, # temp until next page is added and this flow is extended
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
      }.freeze
    end
  end
end
