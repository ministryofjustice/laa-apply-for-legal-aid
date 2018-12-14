module Providers
  class ApplicantsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def show
      @form = Applicants::BasicDetailsForm.new(model: applicant)
    end

    def update
      @form = Applicants::BasicDetailsForm.new(form_params)
      if @form.save
        redirect_to next_step_url
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
