module Providers
  class SubmittedApplicationsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?

    def show
      @source_application = LegalAidApplication.find(legal_aid_application.copy_case_id) if @legal_aid_application.copy_case?
    end
  end
end
