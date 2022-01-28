module Providers
  class SubmittedApplicationsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?

    def show; end

    private

    def display_employment_income?
      Setting.enable_employed_journey? &&
        @legal_aid_application.provider.employment_permissions? &&
        @legal_aid_application.cfe_result.jobs?
    end
  end
end
