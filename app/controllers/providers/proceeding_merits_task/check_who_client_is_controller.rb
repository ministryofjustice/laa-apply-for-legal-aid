module Providers
  module ProceedingMeritsTask
    class CheckWhoClientIsController < ProviderBaseController
      def show
        legal_aid_application.rejected_all_parental_responsibilities!
        @relationship_to_child = @proceeding.relationship_to_child
      end

      def update
        legal_aid_application.provider_enter_merits!
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
