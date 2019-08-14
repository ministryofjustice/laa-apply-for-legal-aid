module Citizens
  module Vehicles
    class EstimatedValuesController < CitizenBaseController
      prefix_step_with :vehicles

      def show
        @form = VehicleForm::EstimatedValueForm.new(model: vehicle)
      end

      def update
        @form = VehicleForm::EstimatedValueForm.new(form_params)

        return go_forward if @form.save

        render :show
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
