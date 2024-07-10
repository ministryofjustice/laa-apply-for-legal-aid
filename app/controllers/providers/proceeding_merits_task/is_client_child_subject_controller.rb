module Providers
  module ProceedingMeritsTask
    class IsClientChildSubjectController < ProviderBaseController
      def show
        @form = Providers::ProceedingMeritsTask::ChildSubjectForm.new(model: proceeding)
      end

      def update; end

    private

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def proceeding
        @proceeding ||= Proceeding.find(merits_task_list_id)
      end

      def merits_task_list_id
        params["merits_task_list_id"]
      end

      def form_params
        merge_with_model(proceeding) do
          params.require(:proceeding).permit(:child_subject)
        end
      end
    end
  end
end
