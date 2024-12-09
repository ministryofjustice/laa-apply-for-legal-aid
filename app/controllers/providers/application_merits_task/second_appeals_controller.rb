module Providers
  module ApplicationMeritsTask
    class SecondAppealsController < ProviderBaseController
      def show
        @form = SecondAppealForm.new(model: legal_aid_application)
      end

      def update
        @form = SecondAppealForm.new(form_params)

        render :show unless update_task_save_continue_or_draft(:application, :second_appeal)
      end

    private

      def form_params
        merge_with_model(legal_aid_application) do
          return {} unless params[:legal_aid_application]

          params.require(:legal_aid_application).permit(:second_appeal)
        end
      end
    end
  end
end
