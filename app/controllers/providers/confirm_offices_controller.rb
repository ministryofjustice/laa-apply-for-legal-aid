module Providers
  class ConfirmOfficesController < ProviderBaseController
    legal_aid_application_not_required!
    helper_method :firm

    def show
      initialize_page_history
      next_page = determine_where_next
      form
      redirect_to next_page unless next_page.nil?
    end

    def update
      if form.valid?
        return redirect_to providers_legal_aid_applications_path if form.confirm_office?

        current_provider.update!(selected_office: nil)
        return redirect_to providers_select_office_path
      end

      render :show
    end

    def invalid_login; end

    private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :confirm_office,
        form_params: form_params
      )
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:confirm_office)
    end

    def determine_where_next
      return providers_invalid_login_path if current_provider.invalid_login?

      if firm.offices.count == 1
        current_provider.update!(selected_office: firm.offices.first)
        return providers_legal_aid_applications_path
      end

      return providers_select_office_path unless current_provider.selected_office

      nil
    end

    def firm
      current_provider.firm
    end

    def initialize_page_history
      session[:page_history_id] = SecureRandom.uuid
    end
  end
end
