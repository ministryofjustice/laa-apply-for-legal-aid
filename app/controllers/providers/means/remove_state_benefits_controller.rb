module Providers
  module Means
    class RemoveStateBenefitsController < ProviderBaseController
      def show
        form
        regular_transaction
      end

      def update
        if form.valid?
          regular_transaction&.destroy! if form.remove_state_benefit?
          if applicant_state_benefits.count.zero?
            replace_last_page_in_history(submitted_providers_legal_aid_applications_path)
          end
          return go_forward(applicant_state_benefits.any?)
        end

        regular_transaction
        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :remove_state_benefit,
          form_params:,
        )
      end

      def applicant_state_benefits
        legal_aid_application.applicant.state_benefits
      end

      def regular_transaction
        @regular_transaction ||= legal_aid_application.regular_transactions.find(params[:id])
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:remove_state_benefit)
      end
    end
  end
end
