module Flow
  module Flows
    class ProviderBlocked < FlowSteps
      STEPS = {
        providers_blocked: {
          path: ->(application) { urls.providers_legal_aid_application_block_path(application) },
        },
      }.freeze
    end
  end
end
