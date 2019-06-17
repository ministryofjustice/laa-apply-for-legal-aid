module Providers
  class SuccessLikelyController < ProviderBaseController
    before_action :authorize_legal_aid_application

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

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end

    def form_params
      merge_with_model(merits_assessment) do
        next {} unless params[:merits_assessment]

        params.require(:merits_assessment).permit(:success_likely)
      end
    end
  end
end
