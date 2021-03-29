module Providers
  class NoOutgoingsSummariesController < ProviderBaseController
    def show
      form
    end

    def update
      return go_forward(form.no_outgoings_summaries?) if form.valid?

      render :show
    end

    private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :no_outgoings_summaries,
        form_params: form_params
      )
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:no_outgoings_summaries)
    end
  end
end
