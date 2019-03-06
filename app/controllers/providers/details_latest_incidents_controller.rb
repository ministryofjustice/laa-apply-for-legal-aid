module Providers
  class DetailsLatestIncidentsController < ProviderBaseController
    def show
      authorize legal_aid_application
      @form = Incidents::LatestIncidentForm.new(model: incident)
    end

    private

    def incident
      legal_aid_application.latest_incident || legal_aid_application.build_latest_incident
    end
  end
end
