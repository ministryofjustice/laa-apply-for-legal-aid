module Providers
  class RespondentsController < ProviderBaseController
    def show
      @form = Respondents::RespondentForm.new(model: respondent)
    end

    def update
      @form = Respondents::RespondentForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def respondent
      @respondent ||= legal_aid_application.respondent || legal_aid_application.build_respondent
    end

    def form_params
      merge_with_model(respondent) do
        params.require(:respondent).permit(
          :understands_terms_of_court_order, :understands_terms_of_court_order_details,
          :warning_letter_sent, :warning_letter_sent_details,
          :police_notified, :police_notified_details_true, :police_notified_details_false,
          :bail_conditions_set, :bail_conditions_set_details, :full_name
        )
      end
    end
  end
end
