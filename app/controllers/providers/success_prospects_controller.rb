module Providers
  class SuccessProspectsController < ProviderBaseController
    def show
      @form = ChancesOfSuccesses::SuccessProspectForm.new(model: chances_of_success)
    end

    def update
      @form = ChancesOfSuccesses::SuccessProspectForm.new(form_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def chances_of_success
      @chances_of_success ||= legal_aid_application.chances_of_success || legal_aid_application.build_chances_of_success
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
