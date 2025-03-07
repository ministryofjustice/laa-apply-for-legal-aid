module Providers
  module ApplicationMeritsTask
    class NatureOfUrgenciesController < ProviderBaseController
      def show
        @form = ApplicationMeritsTask::NatureOfUrgencyForm.new(model: urgency)
      end

      def update
        @form = ApplicationMeritsTask::NatureOfUrgencyForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :nature_of_urgency)
      end

    private

      def urgency
        legal_aid_application.urgency || legal_aid_application.build_urgency
      end

      def form_params
        merged_params = merge_with_model(urgency) do
          params.expect(application_merits_task_urgency: %i[nature_of_urgency hearing_date_set hearing_date])
        end
        convert_date_params(merged_params)
      end
    end
  end
end
