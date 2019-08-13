module Providers
  class SuccessProspectsController < ProviderBaseController
    def show
      @form = MeritsAssessments::SuccessProspectForm.new(model: merits_assessment)
    end

    def update
      @form = MeritsAssessments::SuccessProspectForm.new(form_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end

    def form_params
      merge_with_model(merits_assessment) do
        params.require(:merits_assessment).permit(:success_prospect, :success_prospect_details)
      end
    end
  end
end
