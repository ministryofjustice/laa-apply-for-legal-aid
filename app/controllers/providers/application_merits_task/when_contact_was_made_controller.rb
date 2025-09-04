module Providers
  module ApplicationMeritsTask
    class WhenContactWasMadeController < ProviderBaseController
      def show
        @form = Incidents::WhenContactWasMadeForm.new(model: incident)
      end

      def update
        @form = Incidents::WhenContactWasMadeForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :when_contact_was_made)
      end

    private

      def incident
        legal_aid_application.latest_incident || legal_aid_application.build_latest_incident
      end

      def form_params
        merged_params = merge_with_model(incident) do
          params.expect(application_merits_task_incident: %i[first_contact_date])
        end
        convert_date_params(merged_params)
      end
    end
  end
end
