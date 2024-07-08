module Providers
  module ProceedingMeritsTask
    class DoesClientHaveParentalResponsibilitiesController < ProviderBaseController
      def show
        @form = Providers::ProceedingMeritsTask::ParentalResponsibilitiesForm.new(model: proceeding)
      end

      def update
        @form = Providers::ProceedingMeritsTask::ParentalResponsibilitiesForm.new(form_params)
        # TODO: change the following to redirect to question 3 when it is added
        return redirect_to providers_legal_aid_application_merits_task_list_path(legal_aid_application) unless yes_choice.include?(@form.relationship_to_child)

        render :show unless update_task_save_continue_or_draft(proceeding.ccms_code.to_sym, :client_relationship_to_proceeding)
      end

    private

      def yes_choice
        %w[court_order parental_responsibility_agreement]
      end

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
