module Providers
  class ApplicantEmployedController < ProviderBaseController
    def index
      @legal_aid_application.reset_from_use_ccms! if @legal_aid_application.use_ccms?
      @form = Applicants::EmployedForm.new(model: applicant)
    end

    def create
      @form = Applicants::EmployedForm.new(form_params)
      render :index unless save_continue_or_draft(@form)
    end

    private

    def applicant
      legal_aid_application.applicant || legal_aid_application.build_applicant
    end

    def form_params
      merge_with_model(applicant) do
        next {} unless params[:applicant]

        params.require(:applicant).permit(:employed)
      end
    end
  end
end
