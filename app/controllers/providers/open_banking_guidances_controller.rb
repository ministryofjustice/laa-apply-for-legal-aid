module Providers
  class OpenBankingGuidancesController < ProviderBaseController
    def show
      legal_aid_application.reset_from_use_ccms! if legal_aid_application.use_ccms?
      legal_aid_application.provider_confirm_applicant_eligibility!

      form
    end

    def update
      return continue_or_draft if draft_selected?

      return go_forward(form.can_client_use_truelayer?) if form.valid?

      render :show
    end

  private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :can_client_use_truelayer,
        form_params:,
      )
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.expect(binary_choice_form: [:can_client_use_truelayer])
    end
  end
end
