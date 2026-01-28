module Providers
  class ReviewAndPrintApplicationsController < ProviderBaseController
    include TransactionTypeSettable

    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?

    def show
      @source_application = @legal_aid_application.copy_case? ? LegalAidApplication.find(legal_aid_application.copy_case_id) : @legal_aid_application
      @read_only = true
    end

    def continue
      unless draft_selected?
        legal_aid_application.merits_complete!(current_provider)
        legal_aid_application.generate_reports!
      end
      continue_or_draft
    end
  end
end
