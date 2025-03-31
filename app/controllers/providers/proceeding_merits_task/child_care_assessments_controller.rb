module Providers
  module ProceedingMeritsTask
    class ChildCareAssessmentsController < ProviderBaseController
      include DeleteAttachments

      def show
        @form = ChildCareAssessmentForm.new(model: child_care_assessment)
        @display_banner = local_authority_assessment_attached?
      end

      def update
        @form = ChildCareAssessmentForm.new(form_params.merge(proceeding_id: proceeding.id))

        if @form.assessed?
          save_continue_or_draft(@form)
        else
          delete_evidence(local_authority_assessment_evidence) if local_authority_assessment_attached?

          render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :client_child_care_assessment)
        end
      end

    private

      def child_care_assessment
        @child_care_assessment ||= proceeding.child_care_assessment || proceeding.build_child_care_assessment
      end

      def proceeding
        @proceeding ||= Proceeding.find(params[:merits_task_list_id])
      end

      def legal_aid_application
        @legal_aid_application ||= proceeding.legal_aid_application
      end

      def local_authority_assessment_attached?
        local_authority_assessment_evidence.present?
      end

      def local_authority_assessment_evidence
        @local_authority_assessment_evidence ||= find_attachments_starting_with("local_authority_assessment")
      end

      def form_params
        merge_with_model(child_care_assessment) do
          params
            .expect(
              proceeding_merits_task_child_care_assessment: [:assessed],
            )
        end
      end
    end
  end
end
