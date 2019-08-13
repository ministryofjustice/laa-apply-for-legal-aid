module Providers
  module Vehicles
    class RegularUsesController < ProviderBaseController
      prefix_step_with :vehicles

      def show
        @form = VehicleForm::UsedRegularlyForm.new(model: vehicle)
      end

      def update
        @form = VehicleForm::UsedRegularlyForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

      private

      def vehicle
        @vehicle = legal_aid_application.vehicle
      end

      def form_params
        return { model: vehicle } if form_submitted_without_selection?

        merge_with_model(vehicle) do
          params.require(:vehicle).permit(:used_regularly)
        end
      end

      def form_submitted_without_selection?
        params[:vehicle].nil?
      end
    end
  end
end
