module Provider
  class LegalAidApplicationsController < ActionController::Base
    layout 'application'
    before_action :set_legal_aid_application, only: [:show, :edit, :update, :destroy]

    # GET /provider/legal_aid_applications
    def index
    end

    # GET /provider/legal_aid_applications/new
    def new
      @legal_aid_application = LegalAidApplication.new
    end

    # POST /provider/legal_aid_applications
    def create
      @legal_aid_application = LegalAidApplication.new
      @legal_aid_application.proceeding_types << proceeding_type

      if @legal_aid_application.save
        redirect_to new_provider_legal_aid_application_applicant_path(@legal_aid_application), notice: "Legal aid application was successfully created.#{params}"
      else
        render :new
      end
    end

    private

      def proceeding_type
        @proceeding_type ||= ProceedingType.find_by!(code: params[:proceeding_type])
      end
  end
end
