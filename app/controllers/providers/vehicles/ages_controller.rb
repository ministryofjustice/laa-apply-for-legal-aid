module Providers
  module Vehicles
    class AgesController < ProviderBaseController
      prefix_step_with :vehicles

      def show
        @form = VehicleForm::AgeForm.new(model: vehicle)
      end

      def update
        @form = VehicleForm::AgeForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

      private

      def vehicle
        @vehicle = legal_aid_application.vehicle
      end

      def form_params
        return { model: vehicle } if form_submitted_without_selection?

        merge_with_model(vehicle) do
          params.require(:vehicle).permit(:more_than_three_years_old)
        end
      end

      def form_submitted_without_selection?
        params[:vehicle].nil?
      end
    end
  end
end
