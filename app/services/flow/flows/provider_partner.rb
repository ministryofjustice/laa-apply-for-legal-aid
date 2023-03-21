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
      }.freeze
    end
  end
end
