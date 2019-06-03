module Providers
  module Vehicles
    class PurchaseDatesController < ProviderBaseController
      prefix_step_with :vehicles

      def show
        authorize legal_aid_application
        @form = VehicleForm::PurchaseDateForm.new(model: vehicle)
      end

      def update
        authorize legal_aid_application
        @form = VehicleForm::PurchaseDateForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

      private

      def vehicle
        legal_aid_application.vehicle
      end

      def form_params
        merge_with_model(vehicle, mode: :provider) do
          params.require(:vehicle).permit(:purchased_on_year, :purchased_on_month, :purchased_on_day)
        end
      end
    end
  end
end
