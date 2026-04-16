module Providers
  class ReviewAndPrintApplicationsController < ProviderBaseController
    include TransactionTypeSettable

    authorize_with_policy_method :show_submitted_application?
    helper_method :display_employment_income?

    def show
      @source_application = @legal_aid_application.copy_case? ? LegalAidApplication.find(legal_aid_application.copy_case_id) : @legal_aid_application
      @read_only = true
      @provider = current_provider
      @office_address = office_address if @provider.selected_office.present?
    end

    def continue
      unless draft_selected?
        legal_aid_application.merits_complete!(current_provider)
        legal_aid_application.generate_reports!
      end
      continue_or_draft
    end

  private

    def office_address
      helpers.office_address_one_line(PDA::OfficeAddressRetriever.call(@provider.selected_office.code))
    rescue PDA::OfficeAddressRetriever::NotFoundError
      I18n.t("providers.review_and_print_applications.show.office_address_not_found")
    rescue PDA::OfficeAddressRetriever::ApiError
      I18n.t("providers.review_and_print_applications.show.office_address_not_available")
    end
  end
end
