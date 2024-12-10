module Providers
  module ProceedingMeritsTask
    class SpecificIssueController < ProviderBaseController
      def show
        @form = SpecificIssueForm.new(model: specific_issue)
      end

      def update
        @form = SpecificIssueForm.new(form_params.merge(proceeding_id: proceeding.id))
        render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :specific_issue)
      end

    private

      def specific_issue
        @specific_issue ||= proceeding.specific_issue || proceeding.build_specific_issue
      end

      def proceeding
        @proceeding ||= Proceeding.find(params[:merits_task_list_id])
      end

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def form_params
        merge_with_model(specific_issue) do
          params.require(:proceeding_merits_task_specific_issue).permit(:details)
        end
      end
    end
  end
end
