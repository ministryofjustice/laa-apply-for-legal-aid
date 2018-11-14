module Providers
  class LegalAidApplicationsController < BaseController
    # GET /provider/applications
    def index; end

    # GET /provider/applications/new
    def new
      proceeding_types
      @legal_aid_application = LegalAidApplication.new
    end

    # POST /provider/applications
    def create
      @legal_aid_application = LegalAidApplication.new(app_params)

      if @legal_aid_application.save
        redirect_to new_providers_legal_aid_application_applicant_path(@legal_aid_application)
      else
        proceeding_types
        render :new
      end
    end

    private

    def app_params
      { proceeding_type_codes: Array(permitted_params[:proceeding_type]) }
    end

    def permitted_params
      params.permit(:proceeding_type)
    end

    def proceeding_types
      @proceeding_types ||= ProceedingType.all
    end
  end
end
