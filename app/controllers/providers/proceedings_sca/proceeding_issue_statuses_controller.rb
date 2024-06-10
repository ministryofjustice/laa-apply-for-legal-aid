module Providers
  module ProceedingsSCA
    class ProceedingIssueStatusesController < ProviderBaseController
      def show
        @proceeding = legal_aid_application.proceedings.last
        form
      end

      def update
        @proceeding = legal_aid_application.proceedings.last
        form

        if form.valid?
          return redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "proceeding_issue_status") unless form.proceeding_issue_status?

          return go_forward
        end
        render :show, status: :unprocessable_entity
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :proceeding_issue_status,
          form_params:,
          error: error_message,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:proceeding_issue_status)
      end

      def error_message
        I18n.t("providers.proceedings_sca.proceeding_issue_statuses.show.error")
      end
    end
  end
end
