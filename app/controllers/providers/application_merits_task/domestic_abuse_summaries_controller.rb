module Providers
  module ApplicationMeritsTask
    class DomesticAbuseSummariesController < ProviderBaseController
      def show
        @form = ApplicationMeritsTask::DomesticAbuseSummaryForm.new(model: domestic_abuse_summary)
      end

      def update
        @form = ApplicationMeritsTask::DomesticAbuseSummaryForm.new(form_params)
        render :show unless update_task_save_continue_or_draft(:application, :domestic_abuse_summary)
      end

    private

      def domestic_abuse_summary
        @domestic_abuse_summary ||= legal_aid_application.domestic_abuse_summary || legal_aid_application.build_domestic_abuse_summary
      end

      def form_params
        merge_with_model(domestic_abuse_summary) do
          params.expect(
            application_merits_task_domestic_abuse_summary: [:warning_letter_sent, :warning_letter_sent_details,
                                                             :police_notified, :police_notified_details_true, :police_notified_details_false,
                                                             :bail_conditions_set, :bail_conditions_set_details]
          )
        end
      end
    end
  end
end
