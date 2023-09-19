module Providers
  module Means
    class VehicleDetailsController < ProviderBaseController
      def show
        @form = ::Vehicles::DetailsForm.new(model: vehicle)
        unless legal_aid_application.applicant.has_partner_with_no_contrary_interest?
          legal_aid_application.vehicle.owner = "client"
          legal_aid_application.vehicle.save!
        end
      end

      def new
        @form = ::Vehicles::DetailsForm.new(model: vehicle)
      end

      def update
        @form = ::Vehicles::DetailsForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def vehicle
        @vehicle ||= existing_vehicle || legal_aid_application.vehicles.build
      end

      def existing_vehicle
        legal_aid_application.vehicles.find_by(id: params["id"])
      end

      def form_params
        return { model: vehicle } if params[:vehicle].nil?

        merge_with_model(vehicle) do
          params.require(:vehicle).permit(:owner,
                                          :estimated_value,
                                          :more_than_three_years_old,
                                          :payment_remaining,
                                          :payments_remain,
                                          :used_regularly)
        end
      end
    end
  end
end
