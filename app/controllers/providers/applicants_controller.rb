module Providers
  class ApplicantsController < ProviderBaseController
    def show
      authorize @legal_aid_application
      @form = Applicants::BasicDetailsForm.new(model: applicant)
    end

    def update
      authorize @legal_aid_application
      @form = Applicants::BasicDetailsForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def applicant
      legal_aid_application.applicant || legal_aid_application.build_applicant
    end

    def applicant_params
      params.require(:applicant).permit(:first_name, :last_name, :dob_day, :dob_month, :dob_year, :national_insurance_number, :email)
    end

    def form_params
      applicant_params.merge(model: applicant)
    end
  end
end
