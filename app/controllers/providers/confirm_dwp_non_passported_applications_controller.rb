module Providers
  class ConfirmDWPNonPassportedApplicationsController < ProviderBaseController
    include ApplicantDetailsCheckable
    helper_method :display_hmrc_text?

    def show
      delete_check_benefits_from_history
      form
    end

    def update
      return continue_or_draft if draft_selected?

      if form.valid?
        details_checked! if correct_dwp_result? && !details_checked?
        HMRC::CreateResponsesService.call(legal_aid_application) if make_hmrc_call?
        return go_forward(correct_dwp_result?)
      end

      render :show
    end

  private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :correct_dwp_result,
        form_params:,
      )
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:correct_dwp_result)
    end

    def delete_check_benefits_from_history
      return if page_history.empty?

      temp_page_history = page_history
      temp_page_history.delete_if { |path| path.include?("check_benefits") }
      page_history_service.write(temp_page_history)
    end

    def correct_dwp_result?
      form.correct_dwp_result?
    end

    def hmrc_call_enabled?
      Rails.configuration.x.collect_hmrc_data
    end

    def make_hmrc_call?
      hmrc_call_enabled?
    end

    alias_method :display_hmrc_text?, :make_hmrc_call?
  end
end
