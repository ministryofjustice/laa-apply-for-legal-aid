module Providers
  module Means
    class RemoveVehiclesController < ProviderBaseController
      def show
        vehicle
        form
      end

      def update
        vehicle

        if form.valid?
          vehicle&.destroy! if form.remove_vehicle?
          if legal_aid_application.vehicles.count.zero?
            legal_aid_application.update!(own_vehicle: nil)
            replace_last_page_in_history(submitted_providers_legal_aid_applications_path)
          end
          return go_forward(legal_aid_application.vehicles.any?)
        end

        render :show
      end

    private

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :remove_vehicle,
          form_params:,
          error: error_message,
        )
      end

      def vehicle
        @vehicle ||= legal_aid_application.vehicles.find(params[:id])
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.expect(binary_choice_form: [:remove_vehicle])
      end

      def error_message
        I18n.t("providers.means.remove_vehicles.show.error")
      end
    end
  end
end
