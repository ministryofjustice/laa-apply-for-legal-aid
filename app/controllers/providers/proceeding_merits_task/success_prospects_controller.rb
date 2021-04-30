module Providers
  module ProceedingMeritsTask
    class SuccessProspectsController < ProviderBaseController
      def show
        @form = ChancesOfSuccesses::SuccessProspectForm.new(model: chances_of_success)
      end

      def update
        @form = ChancesOfSuccesses::SuccessProspectForm.new(form_params)

        render :show unless save_continue_or_draft(@form)
      end

      private

      def legal_aid_application
        @legal_aid_application ||= application_proceeding_type.legal_aid_application
      end

      def chances_of_success
        @chances_of_success ||= application_proceeding_type.chances_of_success || application_proceeding_type.build_chances_of_success
      end

      def application_proceeding_type
        @application_proceeding_type = ApplicationProceedingType.find(params[:application_proceeding_type_id])
      end

      def form_params
        merge_with_model(chances_of_success) do
          params.require(:proceeding_merits_task_chances_of_success).permit(:success_prospect, :success_prospect_details,
                                                                            :success_prospect_details_poor, :success_prospect_details_marginal,
                                                                            :success_prospect_details_borderline, :success_prospect_details_not_known)
        end
      end
    end
  end
end
