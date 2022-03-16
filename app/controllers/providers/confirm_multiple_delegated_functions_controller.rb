module Providers
  class ConfirmMultipleDelegatedFunctionsController < ProviderBaseController
    def show
      proceedings_by_name
      form
    end

    def update
      return continue_or_draft if draft_selected?

      proceedings_by_name
      return go_forward(form.confirm_multiple_delegated_functions_date?) if form.valid?

      render :show
    end

  private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :confirm_multiple_delegated_functions_date,
        form_params: form_params,
        error: multiple_dates_check? ? 'error.blank_plural' : 'error.blank_singular'
      )
    end

    def multiple_dates_check?
      @multiple_dates_check ||= legal_aid_application.proceedings.uniq.select { |item| item.used_delegated_functions_on.present? }.many?
    end

    def proceedings_by_name
      @proceedings_by_name ||= legal_aid_application.proceedings_by_name
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:confirm_multiple_delegated_functions_date)
    end
  end
end
