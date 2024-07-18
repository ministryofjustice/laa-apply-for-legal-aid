module Providers
  module ProceedingMeritsTask
    class DoesClientHaveParentalResponsibilitiesController < ProviderBaseController
      def show
        @form = Providers::ProceedingMeritsTask::ParentalResponsibilitiesForm.new(model: proceeding)
      end

      def update
        @form = Providers::ProceedingMeritsTask::ParentalResponsibilitiesForm.new(form_params)
        if @form.relationship_to_child.eql?("false") && !draft_selected?
          @form.save!
          return redirect_to providers_merits_task_list_is_client_child_subject_path(merits_task_list_id)
        end

        render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :client_relationship_to_proceeding)
      end

    private

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def proceeding
        @proceeding ||= Proceeding.find(merits_task_list_id)
      end

      def merits_task_list_id
        params["merits_task_list_id"]
      end

      def form_params
        merge_with_model(proceeding) do
          params.require(:proceeding).permit(:relationship_to_child)
        end
      end
    end
  end
end
