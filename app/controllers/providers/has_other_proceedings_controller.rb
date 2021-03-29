module Providers
  class HasOtherProceedingsController < ProviderBaseController
    def show
      return go_forward unless Setting.allow_multiple_proceedings?

      form
      proceeding_types
    end

    def update
      return continue_or_draft if draft_selected?
      return go_forward(form.has_other_proceeding?) if form.valid?

      render :show
    end

    def destroy
      remove_proceeding
      return redirect_to providers_legal_aid_application_proceedings_types_path if proceeding_types.empty?

      form
      render :show
    end

    private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :has_other_proceeding,
        form_params: update_form_params
      )
    end

    def proceeding_types
      @proceeding_types ||= legal_aid_application.proceeding_types
    end

    def proceeding_type
      proceeding_types.find_by(code: form_params[:id])
    end

    def remove_proceeding
      LegalFramework::RemoveProceedingTypeService.call(legal_aid_application, proceeding_type)
    end

    def form_params
      params[:action] == 'destroy' ? destroy_form_params : update_form_params
    end

    def destroy_form_params
      params.permit(:id)
    end

    def update_form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:has_other_proceeding)
    end
  end
end
