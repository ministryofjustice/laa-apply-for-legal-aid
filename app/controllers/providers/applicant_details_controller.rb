module Providers
  class ApplicantDetailsController < ProviderBaseController
    include PreDWPCheckVisible

    def show
      @form = Applicants::BasicDetailsForm.new(model: applicant)
    end

    def update
      @form = Applicants::BasicDetailsForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def applicant
      legal_aid_application.applicant || legal_aid_application.build_applicant
    end

    def form_params
      merged_params = merge_with_model(applicant) do
        params.require(:applicant).permit(:first_name, :last_name, :national_insurance_number, :date_of_birth)
      end
      convert_date_params(merged_params)
    end
  end
end
