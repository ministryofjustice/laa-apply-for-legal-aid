module Providers
  class ProceedingsTypesController < ProviderBaseController
    include PreDWPCheckVisible

    # GET /provider/applications/:legal_aid_application_id/proceedings_types
    def index
      proceeding_types
      excluded_codes
    end

    # POST /provider/applications/:legal_aid_application_id/proceedings_types
    def create
      return continue_or_draft if draft_selected?

      if run_transaction
        go_forward
      else
        legal_aid_application.errors.add(:'proceeding-search-input', t(".search_and_select"))
        proceeding_types
        excluded_codes
        render :index
      end
    end

  private

    def run_transaction
      proceeding_to_add = proceeding_types.find { |proceeding| proceeding.ccms_code == form_params }
      add_proceeding_service.call(ccms_code: proceeding_to_add.ccms_code)
    rescue ActionController::ParameterMissing
      false
    end

    def add_proceeding_service
      LegalFramework::AddProceedingService.new(legal_aid_application)
    end

    def form_params
      params.require(:id)
    end

    def proceeding_types
      @proceeding_types ||= LegalFramework::ProceedingTypes::All.call
    end

    def excluded_codes
      @excluded_codes ||= legal_aid_application.proceedings&.map { |p| p.ccms_code }&.join(",")
    end
  end
end
