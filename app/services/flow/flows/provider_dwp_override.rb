module Flow
  module Flows
    class ProviderDWPOverride < FlowSteps # rubocop:disable Metrics/ClassLength
      STEPS = {
        confirm_dwp_non_passported_applications: {
          path: ->(application) { urls.providers_legal_aid_application_confirm_dwp_non_passported_applications_path(application) },
          forward: :check_benefits
          # uncomment the below to redirect to next pages being developed and remove line 7
          # forward: ->(_application, confirm_dwp_non_passported) { confirm_dwp_non_passported ? :check_benefits : :check_client_details }
        }
      }.freeze
    end
  end
end
