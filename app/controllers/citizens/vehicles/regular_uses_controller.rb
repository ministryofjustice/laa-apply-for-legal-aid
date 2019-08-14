module Citizens
  module Vehicles
    class RegularUsesController < CitizenBaseController
      prefix_step_with :vehicles

      def show
        @form = VehicleForm::UsedRegularlyForm.new(model: vehicle)
      end

      def update
        @form = VehicleForm::UsedRegularlyForm.new(form_params)

        return go_forward if @form.save

        render :show
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
