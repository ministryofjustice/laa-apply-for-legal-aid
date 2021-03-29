module Providers
  class CheckClientDetailsController < ProviderBaseController
    def show
      applicant
      form
    end

    def update
      return continue_or_draft if draft_selected?

      applicant
      return go_forward(form.check_client_details?) if form.valid?

      render :show
    end

    private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :check_client_details,
        form_params: form_params
      )
    end

    def applicant
      @applicant ||= legal_aid_application.applicant || legal_aid_application.build_applicant
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:check_client_details)
    end
  end
end
