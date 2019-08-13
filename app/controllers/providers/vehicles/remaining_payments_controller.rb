module Providers
  module Vehicles
    class RemainingPaymentsController < ProviderBaseController
      prefix_step_with :vehicles

      def show
        @form = VehicleForm::RemainingPaymentForm.new(model: vehicle)
      end

      def update
        @form = VehicleForm::RemainingPaymentForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

      private

      def vehicle
        legal_aid_application.vehicle
      end

      def form_params
        merge_with_model(vehicle) do
          params.require(:vehicle).permit(:payment_remaining, :payments_remain)
        end
      end
    end
  end
end
