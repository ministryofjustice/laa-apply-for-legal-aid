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
        legal_aid_application.errors.add(:'proceeding-search-input', t('.search_and_select'))
        proceeding_types
        excluded_codes
        render :index
      end
    end

    # PATCH /provider/applications/:legal_aid_application_id/proceedings_types/:id
    # TODO: Could be removed after multiple proceedings go live.
    def update
      run_transaction
      go_forward
    end

    private

    def run_transaction
      # TODO: Should be fixed by future LFA ticket to change to Proceeding record
      id = ProceedingType.find_by(ccms_code: form_params).id
      proceeding_types_service.add(proceeding_type_id: id, scope_type: :substantive)
    rescue ActionController::ParameterMissing
      false
    end

    def proceeding_types_service
      LegalFramework::ProceedingTypesService.new(legal_aid_application)
    end

    def form_params
      params.require(:id)
    end

    def proceeding_types
      @proceeding_types ||= LegalFramework::ProceedingTypes::All.call
    end

    def excluded_codes
      @excluded_codes ||= legal_aid_application.application_proceeding_types&.map { |p| p.proceeding_type.ccms_code }&.join(',')
    end
  end
end
