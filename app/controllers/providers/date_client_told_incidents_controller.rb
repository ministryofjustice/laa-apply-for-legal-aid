module Providers
  class DateClientToldIncidentsController < ProviderBaseController
    def show
      authorize legal_aid_application
      @form = Incidents::ToldOnForm.new(model: incident)
    end

    def update
      authorize legal_aid_application
      @form = Incidents::ToldOnForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def incident
      legal_aid_application.latest_incident || legal_aid_application.build_latest_incident
    end

    def form_params
      merge_with_model(incident) do
        params.require(:incident).permit(
          :told_day, :told_month, :told_year
        )
      end
    end
  end
end
