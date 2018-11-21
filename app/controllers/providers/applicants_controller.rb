module Providers
  class ApplicantsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    before_action :set_current_step

    def new
      @form = Applicants::BasicDetailsForm.new
    end

    def create
      @form = Applicants::BasicDetailsForm.new(new_params)
      if @form.save
        redirect_to action_for_next_step(options: { applicant: @form.model })
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

    def set_current_step
      @current_step = :basic_details
    end
  end
end
