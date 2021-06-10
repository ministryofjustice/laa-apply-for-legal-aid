module Providers
  module ProceedingMeritsTask
    class ChancesOfSuccessController < ProviderBaseController
      def index
        @form = ChancesOfSuccesses::SuccessLikelyForm.new(model: chances_of_success)
      end

      def create
        @form = ChancesOfSuccesses::SuccessLikelyForm.new(form_params)
        render :index unless update_task_save_continue_or_draft(proceeding_type.ccms_code.to_sym, :chances_of_success)
      end

      private

      def task_list_should_update?
        application_has_task_list? && !draft_selected? && @form.valid? && @form.success_likely.eql?('true')
      end

      def legal_aid_application
        @legal_aid_application ||= application_proceeding_type.legal_aid_application
      end

      def proceeding_type
        @proceeding_type ||= application_proceeding_type.proceeding_type
      end

      def chances_of_success
        @chances_of_success ||= application_proceeding_type.chances_of_success || application_proceeding_type.build_chances_of_success
      end

      def application_proceeding_type
        @application_proceeding_type = ApplicationProceedingType.find(params[:merits_task_list_id])
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
