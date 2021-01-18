module Providers
  class ProceedingsTypesController < ProviderBaseController
    include PreDWPCheckVisible

    # GET /provider/applications/:legal_aid_application_id/proceedings_types
    def index
      @multiple_proceedings = allow_multiple_proceedings?
      proceeding_types
    end

    # POST /provider/applications/:legal_aid_application_id/proceedings_types
    def create
      return continue_or_draft if draft_selected?

      if run_transaction
        go_forward
      else
        legal_aid_application.errors.add(:'proceeding-search-input', t('.search_and_select'))
        @multiple_proceedings = allow_multiple_proceedings?
        proceeding_types
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
      proceeding_types_service.add(proceeding_type_id: form_params, scope_limitation: :substantive)
    rescue ActionController::ParameterMissing
      false
    end

    def proceeding_types_service
      ProceedingTypesService.new(legal_aid_application)
    end

    def form_params
      params.require(:id)
    end

    def proceeding_types
      @proceeding_types ||= ProceedingType.all
    end

    def allow_multiple_proceedings?
      Setting.allow_multiple_proceedings?
    end
  end
end
