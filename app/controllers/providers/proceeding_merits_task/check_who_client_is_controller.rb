module Providers
  module ProceedingMeritsTask
    class CheckWhoClientIsController < ProviderBaseController
      def show
        @relationship_to_child = @proceeding.relationship_to_child
      end

      def update
        continue_or_draft
      end

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
    end
  end
end
