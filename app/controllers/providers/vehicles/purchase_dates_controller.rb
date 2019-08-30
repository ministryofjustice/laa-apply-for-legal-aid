module Providers
  module Vehicles
    class PurchaseDatesController < ProviderBaseController
      prefix_step_with :vehicles

      def show
        @form = VehicleForm::PurchaseDateForm.new(model: vehicle)
      end

      def update
        @form = VehicleForm::PurchaseDateForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

      private

      def vehicle
        legal_aid_application.vehicle
      end

      def form_params
        merge_with_model(vehicle, journey: :providers) do
          params.require(:vehicle).permit(:purchased_on_year, :purchased_on_month, :purchased_on_day)
        end
      end
    end
  end
end
