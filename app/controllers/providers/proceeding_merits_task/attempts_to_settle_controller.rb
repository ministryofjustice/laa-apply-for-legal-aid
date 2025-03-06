module Providers
  module ProceedingMeritsTask
    class AttemptsToSettleController < ProviderBaseController
      def show
        @form = Providers::ProceedingMeritsTask::AttemptsToSettleForm.new(model: attempts_to_settle)
      end

      def update
        @form = Providers::ProceedingMeritsTask::AttemptsToSettleForm.new(form_params.merge(proceeding_id: proceeding.id))
        render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :attempts_to_settle)
      end

    private

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def attempts_to_settle
        @attempts_to_settle ||= proceeding.attempts_to_settle || proceeding.build_attempts_to_settle
      end

      def proceeding
        @proceeding ||= Proceeding.find(merits_task_list_id)
      end

      def merits_task_list_id
        params["merits_task_list_id"]
      end

      def form_params
        merge_with_model(attempts_to_settle) do
          params.expect(proceeding_merits_task_attempts_to_settle: [:attempts_made])
        end
      end
    end
  end
end
