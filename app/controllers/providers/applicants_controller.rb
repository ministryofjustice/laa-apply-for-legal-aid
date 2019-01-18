module Providers
  class ApplicantsController < BaseController
    include ApplicationDependable
    include Steppable
    include SaveAsDraftable

    def show
      authorize @legal_aid_application
      @form = Applicants::BasicDetailsForm.new(model: applicant)
    end

    def update
      authorize @legal_aid_application
      @form = Applicants::BasicDetailsForm.new(form_params)
      if @form.save
        continue_or_save_draft
      else
        render :show
      end
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
