module Providers
  module ApplicationMeritsTask
    class CourtOrderCopiesController < ProviderBaseController
      def show
        @form = ApplicationMeritsTask::PLFCourtOrderForm.new(model: legal_aid_application)
      end

      def update
        @form = ApplicationMeritsTask::PLFCourtOrderForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :court_order_copy)
      end

      def form_params
        merge_with_model(legal_aid_application) do
          return {} unless params[:legal_aid_application]

          params.expect(legal_aid_application: [:plf_court_order])
        end
      end
    end
  end
end
