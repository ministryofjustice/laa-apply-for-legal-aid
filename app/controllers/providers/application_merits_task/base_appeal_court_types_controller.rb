module Providers
  module ApplicationMeritsTask
    class BaseAppealCourtTypesController < ProviderBaseController
      def show
        @form = form.new(model: appeal)
      end

      def update
        @form = form.new(form_params)

        render :show unless update_task_save_continue_or_draft(:application, :second_appeal)
      end

    private

      # :nocov:
      def form
        raise "Implement in subclass"
      end
      # :nocov:

      def appeal
        legal_aid_application.appeal
      end

      def form_params
        merge_with_model(appeal) do
          return {} unless params[:application_merits_task_appeal]

          params.require(:application_merits_task_appeal).permit(:court_type)
        end
      end
    end
  end
end
