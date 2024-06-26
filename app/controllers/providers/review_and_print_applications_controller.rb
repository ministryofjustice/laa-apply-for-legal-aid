module Providers
  class ReviewAndPrintApplicationsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?

    def show
      @source_application = LegalAidApplication.find(legal_aid_application.copy_case_id) if @legal_aid_application.copy_case?
    end

    def continue
      unless draft_selected?
        legal_aid_application.generate_reports!
        legal_aid_application.merits_complete!
      end
      continue_or_draft
    end
  end
end
