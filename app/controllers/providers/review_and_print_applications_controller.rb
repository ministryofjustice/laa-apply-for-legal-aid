module Providers
  class ReviewAndPrintApplicationsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?

    def show
      @show_linked_proceedings = @legal_aid_application.copy_case? && @legal_aid_application.proceedings.count.zero?
      @source_application = @show_linked_proceedings ? LegalAidApplication.find(legal_aid_application.copy_case_id) : legal_aid_application
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
