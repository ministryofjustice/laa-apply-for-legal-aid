module Providers
  module ProceedingsSCA
    class ProceedingIssueStatusesController < ProviderBaseController
      prefix_step_with :proceedings_sca

      def show
        @proceeding = legal_aid_application.proceedings.order(:created_at).last
        form
      end

      def update
        return continue_or_draft if draft_selected?

        @proceeding = legal_aid_application.proceedings.order(:created_at).last

        if form.valid?
          return redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "proceeding_issue_status") unless form.proceeding_issue_status?

          return go_forward(@proceeding)
        end
        render :show, status: :unprocessable_content
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

        params.expect(binary_choice_form: [:proceeding_issue_status])
      end

      def error_message
        I18n.t("providers.proceedings_sca.proceeding_issue_statuses.show.error")
      end
    end
  end
end
