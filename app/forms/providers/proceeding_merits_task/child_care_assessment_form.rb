module Providers
  module ProceedingMeritsTask
    class ChildCareAssessmentForm < BaseForm
      form_for ::ProceedingMeritsTask::ChildCareAssessment

      attr_accessor :proceeding_id, :assessed

      validates :assessed, inclusion: %w[true false], unless: :draft?

      set_callback :save, :before, :sync_result_details

      def assessed?
        attributes["assessed"] == "true"
      end

    private

      def sync_result_details
        if assessed_changed?
          attributes["result"] = nil
          attributes["details"] = nil
        end
      end

      def assessed_changed?
        attributes["assessed"] != model.assessed.to_s
      end
    end
  end
end
