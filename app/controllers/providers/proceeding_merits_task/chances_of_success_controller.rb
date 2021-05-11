module Providers
  module ProceedingMeritsTask
    class ChancesOfSuccessController < ProviderBaseController
      def index
        @form = ChancesOfSuccesses::SuccessLikelyForm.new(model: chances_of_success)
      end

      def create
        @form = ChancesOfSuccesses::SuccessLikelyForm.new(form_params)
        # TODO: Remove SafeNavigators after MultiProceeding Feature flag is turned on
        # Until then, some applications will not have a legal_framework_merits_task_list
        # Afterwards - everything should have one!
        legal_aid_application&.legal_framework_merits_task_list&.mark_as_complete!(proceeding_type.ccms_code.to_sym, :chances_of_success)
        render :index unless save_continue_or_draft(@form)
      end

      private

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
