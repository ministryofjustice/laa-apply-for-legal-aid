module Providers
  module Means
    class VehicleDetailsController < ProviderBaseController
      def show
        @form = ::Vehicles::DetailsForm.new(model: vehicle)
      end

      def update
        @form = ::Vehicles::DetailsForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def vehicle
        @vehicle ||= legal_aid_application.vehicle || legal_aid_application.build_vehicle
      end

      def form_params
        return { model: vehicle } if params[:vehicle].nil?

        merge_with_model(vehicle) do
          params.require(:vehicle).permit(:estimated_value,
                                          :more_than_three_years_old,
                                          :payment_remaining,
                                          :payments_remain,
                                          :used_regularly)
        end
      end
    end
  end
end
