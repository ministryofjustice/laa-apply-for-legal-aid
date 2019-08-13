module Providers
  class SuccessLikelyController < ProviderBaseController
    def index
      @form = MeritsAssessments::SuccessLikelyForm.new(model: merits_assessment)
    end

    def create
      @form = MeritsAssessments::SuccessLikelyForm.new(form_params)

      render :index unless save_continue_or_draft(@form)
    end

    private

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end

    def form_params
      merge_with_model(merits_assessment) do
        next {} unless params[:merits_assessment]

        params.require(:merits_assessment).permit(:success_likely)
      end
    end
  end
end
