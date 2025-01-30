module Providers
  module ApplicationMeritsTask
    class IsMatterOpposedController < ProviderBaseController
      def show
        @form = ApplicationMeritsTask::MatterOpposedForm.new(model: matter_opposition)
      end

      def update
        @form = ApplicationMeritsTask::MatterOpposedForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :matter_opposed)
      end

    private

      def matter_opposition
        legal_aid_application.matter_opposition || legal_aid_application.build_matter_opposition
      end

      def form_params
        merge_with_model(matter_opposition) do
          params.require(:application_merits_task_matter_opposition).permit(:matter_opposed)
        end
      end
    end
  end
end
