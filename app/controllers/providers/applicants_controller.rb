module Providers
  class ApplicantsController < BaseController
    STEPS = {
      new: Applicants::BasicDetailsForm,
      edit: Applicants::EmailForm
    }.freeze

    def new
      @applicant = form_for(:new)
    end

    def create
      @applicant = form_for(:new)
      if @applicant.save
        redirect_to edit_providers_legal_aid_application_applicant_path(@applicant.legal_aid_application)
      else
        render :new
      end
    end

    def edit
      @applicant = form_for(:edit)
    end

    # def update
    #   @applicant = form_for(:edit)
    #   if @applicant.save
    #     render json: { message: 'Write next action!' }
    #   else
    #     render :edit
    #   end
    # end

    private

    def form_for(step)
      STEPS[step].new(params.permit!)
    end
  end
end
