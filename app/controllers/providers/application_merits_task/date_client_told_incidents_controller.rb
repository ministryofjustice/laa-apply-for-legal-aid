module Providers
  module ApplicationMeritsTask
    class DateClientToldIncidentsController < ProviderBaseController
      def show
        @form = Incidents::ToldOnForm.new(model: incident)
      end

      def update
        @form = Incidents::ToldOnForm.new(form_params)
        # TODO: Remove SafeNavigators after MultiProceeding Feature flag is turned on
        # Until then, some applications will not have a legal_framework_merits_task_list
        # Afterwards - everything should have one!
        legal_aid_application&.legal_framework_merits_task_list&.mark_as_complete!(:application, :latest_incident_details)
        render :show unless save_continue_or_draft(@form)
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
