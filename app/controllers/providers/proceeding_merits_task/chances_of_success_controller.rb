module Providers
  module ProceedingMeritsTask
    class ChancesOfSuccessController < ProviderBaseController
      def index
        @form = ChancesOfSuccesses::SuccessLikelyForm.new(model: chances_of_success)
      end

      def create
        @form = ChancesOfSuccesses::SuccessLikelyForm.new(form_params)

        render :index unless save_continue_or_draft(@form)
      end

      private

      def chances_of_success
        @chances_of_success ||= legal_aid_application.chances_of_success || legal_aid_application.build_chances_of_success
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
