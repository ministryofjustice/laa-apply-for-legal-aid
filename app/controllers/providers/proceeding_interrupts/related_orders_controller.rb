module Providers
  module ProceedingInterrupts
    class RelatedOrdersController < ProviderBaseController
      before_action :proceeding
      def show
        @form = RelatedOrdersForm.new(model: proceeding)
      end

      def update
        @form = RelatedOrdersForm.new(form_params)
        return redirect_to providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "plf_none_selected") if redirect_on_none_selected?

        render :show, status: :unprocessable_content unless save_continue_or_draft(@form, proceeding:)
      end

    private

      def redirect_on_none_selected?
        form_params[:none_selected].present? && !params.key?(:draft_button)
      end

      def proceeding
        @proceeding ||= Proceeding.find(proceeding_id_param)
      end

      def proceeding_id_param
        params.require(:id)
      end

      def form_params
        merge_with_model(proceeding) do
          params
            .require(:proceeding)
            .permit(:none_selected, related_orders: [])
        end
      end
    end
  end
end
