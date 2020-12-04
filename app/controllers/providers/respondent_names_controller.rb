module Providers
  class RespondentNamesController < ProviderBaseController
    def show
      @form = Respondents::RespondentNameForm.new(model: respondent)
    end

    def update
      @form = Respondents::RespondentNameForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def respondent
      @respondent ||= legal_aid_application.respondent || legal_aid_application.build_respondent
    end

    def form_params
      merge_with_model(respondent) do
        params.require(:respondent).permit(:full_name)
      end
    end
  end
end
