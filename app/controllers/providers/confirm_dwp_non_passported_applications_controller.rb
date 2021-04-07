module Providers
  class ConfirmDWPNonPassportedApplicationsController < ProviderBaseController
    def show
      form
    end

    def update
      return continue_or_draft if draft_selected?

      if form.valid?
        details_checked! if form.correct_dwp_result? && !details_checked?
        return go_forward(form.correct_dwp_result?)
      end

      render :show
    end

    private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :correct_dwp_result,
        form_params: form_params
      )
    end

    def details_checked!
      legal_aid_application.applicant_details_checked!
    end

    def details_checked?
      legal_aid_application.applicant_details_checked?
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:correct_dwp_result)
    end
  end
end
