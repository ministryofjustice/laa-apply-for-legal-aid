module Providers
  module ProceedingsSCA
    class ProceedingIssueStatusesController < ProviderBaseController
      def show
        @proceeding = legal_aid_application.proceedings.last
        form
      end

      def update
        form
        go_forward(@form.proceeding_issue_status?) if form.valid?
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :proceeding_issue_status,
          form_params:,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:proceeding_issue_status)
      end
    end
  end
end
