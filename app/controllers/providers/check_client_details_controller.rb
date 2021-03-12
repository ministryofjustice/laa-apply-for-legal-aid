module Providers
  class CheckClientDetailsController < ProviderBaseController
    def show
      applicant
      @form = Providers::CheckClientDetailsForm.new
    end

    def update
      return continue_or_draft if draft_selected?

      applicant
      @form = Providers::CheckClientDetailsForm.new(form_params)

      if @form.valid?
        go_forward(form_params[:check_client_details] == 'true')
      else
        render :show
      end
    end

    private

    def applicant
      @applicant ||= legal_aid_application.applicant || legal_aid_application.build_applicant
    end

    def form_params
      params.require(:providers_check_client_details_form).permit(:check_client_details)
    end
  end
end
