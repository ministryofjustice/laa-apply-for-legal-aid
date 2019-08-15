module Providers
  class EmailAddressesController < ProviderBaseController
    def show
      @form = Applicants::EmailForm.new(model: applicant)
    end

    def update
      @form = Applicants::EmailForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def applicant
      legal_aid_application.applicant || legal_aid_application.build_applicant
    end

    def form_params
      merge_with_model(applicant) do
        params.require(:applicant).permit(:email)
      end
    end
  end
end
