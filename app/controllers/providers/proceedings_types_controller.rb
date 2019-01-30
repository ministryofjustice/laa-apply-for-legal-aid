module Providers
  class ProceedingsTypesController < BaseController
    include ApplicationDependable
    include Steppable

    # GET /provider/applications/:legal_aid_application_id/proceedings_type
    def show
      authorize @legal_aid_application
      @back_step_url = back_step_path unless legal_aid_application.checking_answers?
      proceeding_types
    end

    # POST /provider/applications/:legal_aid_application_id/proceedings_type
    def update
      authorize @legal_aid_application
      if legal_aid_application.update(app_params)
        redirect_to next_step_url
      else
        proceeding_types
        render :show
      end
    end

    private

    def app_params
      { proceeding_type_codes: [permitted_params[:proceeding_type]] }
    end

    def permitted_params
      params.permit(:proceeding_type)
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
