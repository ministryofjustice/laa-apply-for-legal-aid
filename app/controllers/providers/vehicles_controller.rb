module Providers
  class VehiclesController < ProviderBaseController
    def show
      @form = LegalAidApplications::OwnVehicleForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::OwnVehicleForm.new(form_params)

      if @form.save
        legal_aid_application.own_vehicle ? vehicle.save! : vehicle.destroy!
        continue_or_draft
      else
        render :show
      end
    end

    private

    def form_params
      merge_with_model(legal_aid_application, journey: :providers) do
        next {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:own_vehicle)
      end
    end

    def vehicle
      @vehicle = legal_aid_application.vehicle || legal_aid_application.build_vehicle
    end
  end
end
