module Providers
  class OpponentsController < ProviderBaseController
    def show
      @form = Opponents::OpponentForm.new(model: opponent)
    end

    def update
      @form = Opponents::OpponentForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def opponent
      @opponent ||= legal_aid_application.opponent || legal_aid_application.build_opponent
    end

    def form_params
      merge_with_model(opponent) do
        params.require(:application_merits_task_opponent).permit(
          :understands_terms_of_court_order, :understands_terms_of_court_order_details,
          :warning_letter_sent, :warning_letter_sent_details,
          :police_notified, :police_notified_details_true, :police_notified_details_false,
          :bail_conditions_set, :bail_conditions_set_details, :full_name
        )
      end
    end
  end
end
