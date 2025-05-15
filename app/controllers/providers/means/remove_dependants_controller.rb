module Providers
  module Means
    class RemoveDependantsController < ProviderBaseController
      def show
        dependant
        form
      end

      def update
        dependant

        if form.valid?
          dependant&.destroy! if form.remove_dependant?
          if legal_aid_application.dependants.count.zero?
            legal_aid_application.update!(has_dependants: nil)
            replace_last_page_in_history(home_path)
          end
          return go_forward
        end

        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :remove_dependant,
          form_params:,
          error: error_message,
        )
      end

      def dependant
        @dependant ||= legal_aid_application.dependants.find(params[:id])
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:remove_dependant])
      end

      def error_message
        I18n.t("providers.means.remove_dependants.show.error", name: dependant.name)
      end
    end
  end
end
