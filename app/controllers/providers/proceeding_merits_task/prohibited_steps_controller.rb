module Providers
  module ProceedingMeritsTask
    class ProhibitedStepsController < ProviderBaseController
      def show
        @form = ProhibitedStepsForm.new(model: prohibited_steps)
      end

      def update
        @form = ProhibitedStepsForm.new(form_params.merge(proceeding_id: proceeding.id))
        render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :prohibited_steps)
      end

    private

      def prohibited_steps
        @prohibited_steps ||= proceeding.prohibited_steps || proceeding.build_prohibited_steps
      end

      def proceeding
        @proceeding ||= Proceeding.find(params[:merits_task_list_id])
      end

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def form_params
        merge_with_model(prohibited_steps) do
          params
            .expect(
              proceeding_merits_task_prohibited_steps: [:uk_removal,
                                                        :details,
                                                        :confirmed_not_change_of_name],
            )
        end
      end
    end
  end
end
