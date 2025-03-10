module Providers
  module ProceedingMeritsTask
    class VaryOrderController < ProviderBaseController
      def show
        @form = VaryOrderForm.new(model: vary_order)
      end

      def update
        @form = VaryOrderForm.new(form_params.merge(proceeding_id: proceeding.id))
        render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :vary_order)
      end

    private

      def vary_order
        @vary_order ||= proceeding.vary_order || proceeding.build_vary_order
      end

      def proceeding
        @proceeding ||= Proceeding.find(params[:merits_task_list_id])
      end

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def form_params
        merge_with_model(vary_order) do
          params.expect(proceeding_merits_task_vary_order: [:details])
        end
      end
    end
  end
end
