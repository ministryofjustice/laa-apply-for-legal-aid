module Providers
  class ReviewAndPrintApplicationsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?

    def show; end

    def continue
      unless draft_selected?
        legal_aid_application.generate_reports!
        legal_aid_application.merits_complete!
      end
      continue_or_draft
    end

  private

    def display_employment_income?
      Setting.enable_employed_journey? &&
        @legal_aid_application.provider.employment_permissions? &&
        @legal_aid_application.cfe_result.jobs?
    end
  end
end
