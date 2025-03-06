module Providers
  module ProceedingMeritsTask
    class OpponentsApplicationController < ProviderBaseController
      def show
        @form = OpponentsApplicationForm.new(model: opponents_application)
      end

      def update
        @form = OpponentsApplicationForm.new(form_params.merge(proceeding_id: proceeding.id))
        render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :opponents_application)
      end

    private

      def opponents_application
        @opponents_application ||= proceeding.opponents_application || proceeding.build_opponents_application
      end

      def proceeding
        @proceeding ||= Proceeding.find(params[:merits_task_list_id])
      end

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def form_params
        merge_with_model(opponents_application) do
          params.expect(proceeding_merits_task_opponents_application: [:has_opponents_application, :reason_for_applying])
        end
      end
    end
  end
end
