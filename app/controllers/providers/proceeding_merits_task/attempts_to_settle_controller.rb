module Providers
  module ProceedingMeritsTask
    class AttemptsToSettleController < ProviderBaseController
      def show
        @application_proceeding_type = application_proceeding_type
        @form = Providers::ProceedingMeritsTask::AttemptsToSettleForm.new(model: attempts_to_settle)
      end

      def update
        @application_proceeding_type = application_proceeding_type
        @form = Providers::ProceedingMeritsTask::AttemptsToSettleForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

      private

      def attempts_to_settle
        @attempts_to_settle ||= @application_proceeding_type.attempts_to_settle || @application_proceeding_type.build_attempts_to_settle
      end

      def application_proceeding_type
        legal_aid_application.application_proceeding_types.find(proceeding_merits_task_id)
      end

      def proceeding_merits_task_id
        params['proceeding_merits_task_id']
      end

      def form_params
        params.require(:proceeding_merits_task_attempts_to_settle).permit(:attempts_made, :application_proceeding_type_id)
      end
    end
  end
end
