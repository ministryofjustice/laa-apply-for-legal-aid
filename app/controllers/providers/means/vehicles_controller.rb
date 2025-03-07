module Providers
  module Means
    class VehiclesController < ProviderBaseController
      def show
        @form = LegalAidApplications::OwnVehicleForm.new(model: legal_aid_application)
      end

      def update
        @form = LegalAidApplications::OwnVehicleForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def form_params
        merge_with_model(legal_aid_application) do
          next {} unless params[:legal_aid_application]

          params.expect(legal_aid_application: [:own_vehicle])
        end
      end
    end
  end
end
