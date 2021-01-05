module Providers
  class DateClientToldIncidentsController < ProviderBaseController
    def show
      @form = Incidents::ToldOnForm.new(model: incident)
    end

    def update
      @form = Incidents::ToldOnForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def incident
      legal_aid_application.latest_incident || legal_aid_application.build_latest_incident
    end

    def form_params
      merge_with_model(incident) do
        convert_date_params
        params.require(:incident).permit(
          :told_on_1i, :told_on_2i, :told_on_3i, :occurred_on_1i, :occurred_on_2i, :occurred_on_3i
        )
      end
    end
  end
end
