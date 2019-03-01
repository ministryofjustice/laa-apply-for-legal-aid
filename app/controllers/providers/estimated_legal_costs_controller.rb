module Providers
  class EstimatedLegalCostsController < ProviderBaseController
    before_action :authorize_legal_aid_application

    def show
      @form = MeritsAssessments::EstimatedLegalCostForm.new(model: merits_assessment)
    end

    def update
      @form = MeritsAssessments::EstimatedLegalCostForm.new(form_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def form_params
      merge_with_model(merits_assessment) do
        params.require(:merits_assessment).permit(:estimated_legal_cost)
      end
    end

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end
  end
end
