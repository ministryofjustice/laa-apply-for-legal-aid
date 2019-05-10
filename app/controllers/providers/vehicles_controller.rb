module Providers
  class VehiclesController < ProviderBaseController
    def show
      vehicle
    end

    def create
      case form_params[:persisted]
      when 'true'
        create_vehicle_and_continue
      when 'false'
        remove_vehicle_and_continue
      else
        vehicle.errors.add :exists_yes, I18n.t('providers.vehicles.show.nothing_selected')
        render :show
      end
    end

    private

    def create_vehicle_and_continue
      vehicle.save unless vehicle.persisted?
      continue_or_draft
    end

    def remove_vehicle_and_continue
      vehicle.destroy
      continue_or_draft
    end

    def vehicle
      @vehicle = legal_aid_application.vehicle || legal_aid_application.build_vehicle
    end

    def form_params
      params.require(:vehicle).permit(:persisted)
    end
  end
end
