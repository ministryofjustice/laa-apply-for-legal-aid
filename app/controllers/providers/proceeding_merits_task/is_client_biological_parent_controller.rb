module Providers
  module ProceedingMeritsTask
    class IsClientBiologicalParentController < ProviderBaseController
      def show
        legal_aid_application.provider_recording_parental_responsibilities!
        @form = Providers::ProceedingMeritsTask::BiologicalParentForm.new(model: proceeding)
      end

      def update
        @form = Providers::ProceedingMeritsTask::BiologicalParentForm.new(form_params)
        if @form.relationship_to_child.eql?("false") && !draft_selected?
          @form.save!
          return redirect_to providers_merits_task_list_does_client_have_parental_responsibility_path(merits_task_list_id)
        end

        render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :client_relationship_to_proceeding, reshow_check_client: legal_aid_application.merits_parental_responsibilities_all_rejected?)
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
