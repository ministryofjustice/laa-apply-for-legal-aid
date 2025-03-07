module Providers
  module Means
    class HasOtherDependantsController < ProviderBaseController
      def show
        form
      end

      def update
        return continue_or_draft if draft_selected?
        return go_forward(form.has_other_dependant?) if form.valid?

        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :has_other_dependant,
          form_params:,
          error: error_message,
        )
      end

      def error_message
        key_name = legal_aid_application&.applicant&.has_partner_with_no_contrary_interest? ? "error_with_partner" : "error"
        I18n.t("providers.has_other_dependants.show.#{key_name}")
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:has_other_dependant])
      end
    end
  end
end
