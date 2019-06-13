module Providers
  class ApplicantDetailsController < ProviderBaseController
    def show
      authorize legal_aid_application
      @form = Applicants::BasicDetailsForm.new(model: applicant)
    end

    def update
      authorize legal_aid_application
      @form = Applicants::BasicDetailsForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def applicant
      legal_aid_application.applicant || legal_aid_application.build_applicant
    end

    def form_params
      merge_with_model(applicant) do
        params.require(:applicant).permit(
          :first_name, :last_name, :dob_day, :dob_month, :dob_year,
          :national_insurance_number, :email
        )
      end
    end
  end
end
