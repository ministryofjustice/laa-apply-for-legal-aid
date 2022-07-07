module Providers
  module Means
    class RemoveDependantsController < ProviderBaseController
      def show
        form
        dependant
      end

      def update
        if form.valid?
          dependant&.destroy! if form.remove_dependant?
          if legal_aid_application.dependants.count.zero?
            legal_aid_application.update!(has_dependants: nil)
            replace_last_page_in_history(providers_legal_aid_applications_path)
          end
          return go_forward
        end

        dependant
        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :remove_dependant,
          form_params:,
        )
      end

      def dependant
        @dependant ||= legal_aid_application.dependants.find(params[:id])
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:remove_dependant)
      end
    end
  end
end
