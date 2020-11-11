module Providers
  class ProceedingsTypesController < ProviderBaseController
    include PreDWPCheckVisible

    # GET /provider/applications/:legal_aid_application_id/proceedings_types
    def index
      proceeding_types
    end

    # POST /provider/applications/:legal_aid_application_id/proceedings_types
    def create
      return continue_or_draft if draft_selected?

      if legal_aid_application.proceeding_types.present?
        go_forward
      else
        legal_aid_application.errors.add(:'proceeding-search-input', t('.search_and_select'))
        proceeding_types
        render :index
      end
    end

    # PATCH /provider/applications/:legal_aid_application_id/proceedings_types/:id
    def update
      ActiveRecord::Base.transaction do
        legal_aid_application.reset_proceeding_types! # This will probably change when multiple proceeding types implemented!
        legal_aid_application.proceeding_types << proceeding_type
        AddScopeLimitationService.call(legal_aid_application, false)
      end
      go_forward
    end

    private

    def proceeding_type
      @proceeding_type = ProceedingType.find(params[:id])
    end

    def proceeding_types
      @proceeding_types ||= ProceedingType.all
    end
  end
end
