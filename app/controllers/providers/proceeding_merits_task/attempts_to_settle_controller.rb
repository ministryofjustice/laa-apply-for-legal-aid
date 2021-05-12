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
        # TODO: Remove SafeNavigators after MultiProceeding Feature flag is turned on
        # Until then, some applications will not have a legal_framework_merits_task_list
        # Afterwards - everything should have one!
        legal_aid_application&.legal_framework_merits_task_list&.mark_as_complete!(proceeding_type.ccms_code.to_sym, :attempts_to_settle)
        render :show unless save_continue_or_draft(@form)
      end

      private

      def legal_aid_application
        @legal_aid_application ||= application_proceeding_type.legal_aid_application
      end

      def proceeding_type
        @proceeding_type ||= application_proceeding_type.proceeding_type
      end

      def application_proceeding_type
        @application_proceeding_type ||= ApplicationProceedingType.find(merits_task_list_id)
      end

      def attempts_to_settle
        @attempts_to_settle ||= @application_proceeding_type.attempts_to_settle || @application_proceeding_type.build_attempts_to_settle
      end

      def merits_task_list_id
        params['merits_task_list_id']
      end

      def form_params
        merge_with_model(attempts_to_settle) do
          params.require(:proceeding_merits_task_attempts_to_settle).permit(:attempts_made)
        end
      end
    end
  end
end
