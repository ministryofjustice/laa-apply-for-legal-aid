module Providers
  class ChangeOfNamesController < ProviderBaseController
    def show
      @proceeding = legal_aid_application.proceedings.order(:created_at).last
      form
    end

    def update
      return continue_or_draft if draft_selected?

      @proceeding = legal_aid_application.proceedings.order(:created_at).last
      if form.valid?
        return redirect_to providers_legal_aid_application_change_of_names_interrupt_path(legal_aid_application) if form.change_of_name?

        return go_forward
      end
      render :show
    end

  private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :change_of_name,
        form_params:,
        error: error_message,
      )
    end

    def error_message
      I18n.t("providers.change_of_names.error")
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.expect(binary_choice_form: [:change_of_name])
    end
  end
end
