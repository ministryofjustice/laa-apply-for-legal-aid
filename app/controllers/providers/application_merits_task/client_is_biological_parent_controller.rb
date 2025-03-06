module Providers
  module ApplicationMeritsTask
    class ClientIsBiologicalParentController < ProviderBaseController
      prefix_step_with :application_merits_task
      def show
        legal_aid_application.provider_recording_parental_responsibilities!
        @form = Providers::ApplicationMeritsTask::BiologicalParentForm.new(model: applicant)
      end

      def update
        @form = Providers::ApplicationMeritsTask::BiologicalParentForm.new(form_params)
        if @form.relationship_to_children.eql?("false") && !draft_selected?
          @form.save!
          return redirect_to providers_legal_aid_application_client_has_parental_responsibility_path(legal_aid_application)
        end

        render :show unless update_task_save_continue_or_draft(:application, :client_relationship_to_children, reshow_check_client: legal_aid_application.merits_parental_responsibilities_all_rejected?)
      end

    private

      def applicant
        legal_aid_application.applicant
      end

      def form_params
        merge_with_model(applicant) do
          params.expect(applicant: [:relationship_to_children])
        end
      end
    end
  end
end
