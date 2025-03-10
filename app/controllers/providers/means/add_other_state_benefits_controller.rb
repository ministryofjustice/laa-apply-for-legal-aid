module Providers
  module Means
    class AddOtherStateBenefitsController < ProviderBaseController
      def show
        transactions
        form
      end

      def update
        return go_forward(form.add_another_state_benefit?) if form.valid?

        transactions
        render :show, status: :unprocessable_content
      end

    private

      def transactions
        @transactions = legal_aid_application.applicant.state_benefits
      end

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :add_another_state_benefit,
          form_params:,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:add_another_state_benefit])
      end
    end
  end
end
