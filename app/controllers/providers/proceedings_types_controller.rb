module Providers
  class ProceedingsTypesController < ProviderBaseController
    # GET /provider/applications/:legal_aid_application_id/proceedings_types
    def index
      proceeding_types
      excluded_codes
      redirect_to providers_legal_aid_application_has_other_proceedings_path(legal_aid_application) if proceeding_types.count.zero?
    end

    # POST /provider/applications/:legal_aid_application_id/proceedings_types
    def create
      return continue_or_draft if draft_selected?

      added_proceeding = run_transaction
      if added_proceeding
        go_forward(added_proceeding)
      else
        legal_aid_application.errors.add(:"proceeding-search-input", t(".search_and_select"))
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
      @proceeding_types ||= LegalFramework::ProceedingTypes::All.call(legal_aid_application)
    end

    def excluded_codes
      @excluded_codes ||= legal_aid_application.proceedings&.map(&:ccms_code)&.join(",")
    end
  end
end
