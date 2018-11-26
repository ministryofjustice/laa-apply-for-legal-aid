module Providers
  class ApplicantsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def new
      @form = Applicants::BasicDetailsForm.new
    end

    def create
      @form = Applicants::BasicDetailsForm.new(new_params)
      if @form.save
        redirect_to next_step_url
      else
        render :new
      end
    end

    private

    def applicant_params
      params.require(:applicant).permit(:first_name, :last_name, :dob_day, :dob_month, :dob_year, :national_insurance_number)
    end

    def new_params
      applicant_params.merge(legal_aid_application_id: params[:legal_aid_application_id])
    end
  end
end
