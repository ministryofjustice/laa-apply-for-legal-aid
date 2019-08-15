module Providers
  class ProceedingsBeforeTheCourtsController < ProviderBaseController
    def show
      @form = MeritsAssessments::ProceedingsBeforeTheCourtForm.new(model: merits_assessment)
    end

    def update
      @form = MeritsAssessments::ProceedingsBeforeTheCourtForm.new(proceedings_before_the_court_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def proceedings_before_the_court_params
      merge_with_model(merits_assessment) do
        params.require(:merits_assessment).permit(:proceedings_before_the_court, :details_of_proceedings_before_the_court)
      end
    end

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end
  end
end
