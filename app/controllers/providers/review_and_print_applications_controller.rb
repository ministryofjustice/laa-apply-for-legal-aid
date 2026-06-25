module Providers
  class ReviewAndPrintApplicationsController < ProviderBaseController
    include TransactionTypeSettable
    include OfficeAddressHandling

    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?

    def show
      legal_aid_application.update!(return_to_review_and_print: true)
      legal_aid_application.confirm_review_and_print_application! unless legal_aid_application.confirming_reviewing_and_printing_application?
      @source_application = @legal_aid_application.copy_case? ? LegalAidApplication.find(legal_aid_application.copy_case_id) : @legal_aid_application
      @read_only = true
      @office_address = office_address if current_provider.selected_office.present?
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
