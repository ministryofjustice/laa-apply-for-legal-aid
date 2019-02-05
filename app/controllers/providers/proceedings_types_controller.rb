module Providers
  class ProceedingsTypesController < BaseController
    include ApplicationDependable
    include Steppable
    include SaveAsDraftable

    # GET /provider/applications/:legal_aid_application_id/proceedings_types
    def index
      authorize legal_aid_application
      @back_step_url = back_step_path unless legal_aid_application.checking_answers?
      proceeding_types
    end

    # POST /provider/applications/:legal_aid_application_id/proceedings_types
    def create
      authorize legal_aid_application
      if legal_aid_application.proceeding_types.present?
        continue_or_save_draft
      else
        legal_aid_application.errors.add(:'proceeding-search-input', t('.search_and_select'))
        proceeding_types
        render :index
      end
    end

    # PATCH /provider/applications/:legal_aid_application_id/proceedings_types/:id
    def update
      authorize legal_aid_application
      legal_aid_application.proceeding_types.clear # Remove this when multiple proceeding types required!
      legal_aid_application.proceeding_types << proceeding_type unless legal_aid_application.proceeding_types.include?(proceeding_type)
      redirect_to providers_legal_aid_application_proceedings_types_path(legal_aid_application)
    end

    # PATCH /provider/applications/:legal_aid_application_id/proceedings_types/:id
    def destroy
      authorize legal_aid_application
      legal_aid_application.proceeding_types.delete(proceeding_type)
      redirect_to providers_legal_aid_application_proceedings_types_path(legal_aid_application)
    end

    private

    def proceeding_type
      @proceeding_type = ProceedingType.find(params[:id])
    end

    def proceeding_types
      @proceeding_types ||= ProceedingType.all
    end

    def back_step_path
      return providers_legal_aid_application_address_selection_path if applicant.address&.lookup_used?

      providers_legal_aid_application_address_path
    end
  end
end
