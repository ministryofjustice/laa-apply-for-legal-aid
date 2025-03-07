module Providers
  module ApplicationMeritsTask
    class OriginalJudgeLevelsController < ProviderBaseController
      def show
        @form = OriginalJudgeLevelForm.new(model: appeal)
      end

      def update
        @form = OriginalJudgeLevelForm.new(form_params)

        render :show unless update_task_save_continue_or_draft(:application, :second_appeal)
      end

    private

      def appeal
        legal_aid_application.appeal
      end

      def form_params
        merge_with_model(appeal) do
          return {} unless params[:application_merits_task_appeal]

          params.expect(application_merits_task_appeal: [:original_judge_level])
        end
      end
    end
  end
end
