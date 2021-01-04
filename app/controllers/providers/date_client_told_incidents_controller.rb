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
        params.require(:incident).permit(
          :told_year, :told_month, :told_day, :occurred_year, :occurred_month, :occurred_day
          # :told_on_1i, :told_on_2i, :told_on_3i, :occurred_on_1i, :occurred_on_2i, :occurred_on_3i
        )
      end
    end

    def converted_params
      replace = {
        'on(1i)': 'day',
        'on(2i)': 'month',
        'on(3i)': 'year'
      }
      params.transform_keys { |key| key.gsub(/on\(\di\)/, replace) }
    end
  end
end
