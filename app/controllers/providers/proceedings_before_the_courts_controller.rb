module Providers
  class ProceedingsBeforeTheCourtsController < ProviderBaseController
    def show
      @form = ChancesOfSuccesses::ProceedingsBeforeTheCourtForm.new(model: chances_of_success)
    end

    def update
      @form = ChancesOfSuccesses::ProceedingsBeforeTheCourtForm.new(proceedings_before_the_court_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def proceedings_before_the_court_params
      merge_with_model(chances_of_success) do
        params.require(:proceeding_merits_task_chances_of_success).permit(:proceedings_before_the_court, :details_of_proceedings_before_the_court)
      end
    end

    def chances_of_success
      @chances_of_success ||= legal_aid_application.chances_of_success || legal_aid_application.build_chances_of_success
    end
  end
end
