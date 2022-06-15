module Providers
  class SubmittedApplicationsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?

    def show; end
  end
end
