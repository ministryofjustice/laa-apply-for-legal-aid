module Providers
  module ApplicationMeritsTask
    class DateClientToldIncidentsController < ProviderBaseController
      def show
        @form = Incidents::ToldOnForm.new(model: incident)
      end

      def update
        @form = Incidents::ToldOnForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :latest_incident_details)
      end

      private

      def incident
        legal_aid_application.latest_incident || legal_aid_application.build_latest_incident
      end

      def form_params
        merged_params = merge_with_model(incident) do
          params.require(:application_merits_task_incident).permit(:told_on, :occurred_on)
        end
        convert_date_params(merged_params)
      end
    end
  end
end
