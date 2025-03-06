module Providers
  module ProceedingMeritsTask
    class ChildCareAssessmentResultsController < ProviderBaseController
      def show
        @form = ChildCareAssessmentResultForm.new(model: child_care_assessment)
      end

      def update
        @form = ChildCareAssessmentResultForm.new(form_params.merge(proceeding_id: proceeding.id))

        render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :client_child_care_assessment)
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

      def form_params
        merge_with_model(child_care_assessment) do
          params
            .expect(
              proceeding_merits_task_child_care_assessment: [:result,
                                                             :details],
            )
        end
      end
    end
  end
end
