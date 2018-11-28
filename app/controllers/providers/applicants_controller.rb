module Providers
  class ApplicantsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def show
      @form = Applicants::BasicDetailsForm.new(current_params)
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

    def applicant_params
      params.require(:applicant).permit(:first_name, :last_name, :dob_day, :dob_month, :dob_year, :national_insurance_number, :email)
    end

    def form_params
      applicant_params.merge(legal_aid_application_id: params[:legal_aid_application_id])
    end

    def applicant_attributes
      %i[first_name last_name date_of_birth national_insurance_number]
    end

    def current_params
      return unless applicant
      applicant.attributes.symbolize_keys.slice(*applicant_attributes).merge(applicant.dob)
    end
  end
end
