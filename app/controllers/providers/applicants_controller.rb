module Providers
  class ApplicantsController < BaseController
    STEPS = {
      new: { form: :form_name, next_action: :foo }
    }


    # GET /providers/applications/:legal_aid_application_id/applicant/new
    def new
      @applicant = legal_aid_application.build_applicant
    end

    private

    def applicant
      @applicant = legal_aid_application.applicant
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(params[:legal_aid_application_id])
    end
  end
end
