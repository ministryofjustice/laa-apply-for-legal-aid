module Providers
  module Vehicles
    class EstimatedValuesController < ProviderBaseController
      prefix_step_with :vehicles

      def show
        @form = VehicleForm::EstimatedValueForm.new(model: vehicle)
      end

      def update
        @form = VehicleForm::EstimatedValueForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

      private

      def vehicle
        legal_aid_application.vehicle
      end

      def form_params
        merge_with_model(vehicle) do
          params.require(:vehicle).permit(:estimated_value)
        end
      end
    end
  end
end
