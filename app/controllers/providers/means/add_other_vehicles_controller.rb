module Providers
  module Means
    class AddOtherVehiclesController < ProviderBaseController
      def show
        vehicles
        form
      end

      def update
        return go_forward(form.add_another_vehicle?) if form.valid?

        vehicles
        render :show, status: :unprocessable_entity
      end

    private

      def vehicles
        @vehicles = legal_aid_application.vehicles.order(:created_at)
      end

      def form
        @form ||= BinaryChoiceForm.call(
          journey: :provider,
          radio_buttons_input_name: :add_another_vehicle,
          form_params:,
        )
      end

      def form_params
        return {} unless params[:binary_choice_form]

        params.require(:binary_choice_form).permit(:add_another_vehicle)
      end
    end
  end
end
