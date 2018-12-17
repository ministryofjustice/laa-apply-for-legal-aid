module Providers
  class ProceedingsTypesController < BaseController
    include ApplicationDependable
    include Steppable

    # GET /provider/applications/:legal_aid_application_id/proceedings_type
    def show
      proceeding_types
    end

    # POST /provider/applications/:legal_aid_application_id/proceedings_type
    def update
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
  end
end
