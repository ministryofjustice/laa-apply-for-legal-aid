module Providers
  module ProceedingMeritsTask
    class ChancesOfSuccessController < ProviderBaseController
      def index
        @form = ChancesOfSuccesses::SuccessLikelyForm.new(model: chances_of_success)
      end

      def create
        @form = ChancesOfSuccesses::SuccessLikelyForm.new(form_params.merge(proceeding_id: proceeding.id))
        render :index unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :chances_of_success)
      end

    private

      def task_list_should_update?
        application_has_task_list? && !draft_selected? && @form.valid? && @form.success_likely.eql?('true')
      end

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def chances_of_success
        @chances_of_success ||= proceeding.chances_of_success
      end

      def proceeding
        @proceeding ||= Proceeding.find(params[:merits_task_list_id])
      end

      def form_params
        merge_with_model(chances_of_success) do
          next {} unless params[:proceeding_merits_task_chances_of_success]

          params.require(:proceeding_merits_task_chances_of_success).permit(:success_likely)
        end
      end
    end
  end
end
