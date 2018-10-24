module Providers
  class ApplicantsController < BaseController
    STEPS = {
      new: Applicant::BasicDetailsForm
    }


    # GET /providers/applications/:legal_aid_application_id/applicant/new
    def new
      @applicant = form_for(:new)
    end

    private

    def form_for(applicant, step)
      STEPS[step].new(params)
    end

    def applicant
      @applicant = legal_aid_application.applicant
    end
  end
end
