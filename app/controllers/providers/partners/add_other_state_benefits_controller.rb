module Providers
  module Partners
    class AddOtherStateBenefitsController < ProviderBaseController
      prefix_step_with :partner

      def show
        transactions
        form
      end

      def update
        return go_forward(form.add_another_partner_state_benefit?) if form.valid?

        transactions
        render :show, status: :unprocessable_content
      end

    private

      def transactions
        @transactions = legal_aid_application.partner.state_benefits
      end

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :add_another_partner_state_benefit,
          form_params:,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:add_another_partner_state_benefit])
      end
    end
  end
end
