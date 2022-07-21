module Providers
  class OpenBankingGuidancesController < ProviderBaseController
    def show
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

      params.require(:binary_choice_form).permit(:can_client_use_truelayer)
    end
  end
end
