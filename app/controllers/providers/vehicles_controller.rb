module Providers
  class VehiclesController < ProviderBaseController
    def show
      vehicle
    end

    def create
      case params[:exists]
      when 'yes'
        render plain: 'yes'
      when 'no'
        render plain: 'no'
      else
        vehicle.errors.add :exists_yes, I18n.t('providers.vehicles.show.nothing_selected')
        render :show
      end
    end

    private

    def vehicle
      @vehicle = legal_aid_application.vehicle || legal_aid_application.build_vehicle
    end
  end
end
