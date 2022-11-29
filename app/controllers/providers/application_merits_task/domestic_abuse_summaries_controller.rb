module Providers
  module ApplicationMeritsTask
    class DomesticAbuseSummariesController < ProviderBaseController
      def show
        @form = Opponents::DomesticAbuseSummaryForm.new(model: opponent)
      end

      def update
        @form = Opponents::DomesticAbuseSummaryForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :domestic_abuse_summary)
      end

    private

      def opponent
        @opponent ||= legal_aid_application.opponent || legal_aid_application.build_opponent
      end

      def form_params
        merge_with_model(opponent) do
          params.require(:application_merits_task_opponent).permit(
            :warning_letter_sent, :warning_letter_sent_details,
            :police_notified, :police_notified_details_true, :police_notified_details_false,
            :bail_conditions_set, :bail_conditions_set_details
          )
        end
      end
    end
  end
end
