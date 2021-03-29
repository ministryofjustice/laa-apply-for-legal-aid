module Providers
  class NoIncomeSummariesController < ProviderBaseController
    def show
      student_finance
      form
    end

    def update
      return go_forward(form.no_income_summaries?) if form.valid?

      student_finance
      render :show
    end

    private

    def student_finance
      @student_finance ||= legal_aid_application.value_of_student_finance
    end

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :no_income_summaries,
        form_params: form_params
      )
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:no_income_summaries)
    end
  end
end
