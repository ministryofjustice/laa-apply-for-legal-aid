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

    def edit
      @form = Applicants::EmailForm.new(model: applicant)
    end

    def update
      @form = Applicants::EmailForm.new(edit_params)

      if @form.save
        redirect_to(
          action_for_next_step(options: { application: legal_aid_application, applicant: @form.model }),
          # TODO: Remove this - currently just a way of displaying a usable link
          notice: "Email link will be to: #{citizens_legal_aid_application_url(legal_aid_application.generate_secure_id)}"
        )
      else
        render :edit
      end
    end

    private

    def applicant_params
      params.require(:applicant).permit(:first_name, :last_name, :dob_day, :dob_month, :dob_year, :national_insurance_number)
    end

    def new_params
      applicant_params.merge(legal_aid_application_id: params[:legal_aid_application_id])
    end

    def edit_params
      email_params.merge(model: applicant)
    end

    def email_params
      params.require(:applicant).permit(:email)
    end

    def applicant
      @applicant ||= legal_aid_application.applicant
    end

    def set_current_step
      @current_step = %w[edit update].include?(params[:action]) ? :email : :basic_details
    end
  end
end
