module Providers
  module ProceedingMeritsTask
    class ChildCareAssessmentResultForm < BaseForm
      form_for ::ProceedingMeritsTask::ChildCareAssessment

      attr_accessor :proceeding_id, :result, :details

      validates :result, inclusion: %w[true false], unless: :draft?
      validates :details, presence: true, unless: proc { draft? || !details_required? }

      set_callback :validation, :before, :sync_result_details

      def details_required?
        attributes["result"] == "false" || result == false
      end

    private

      def sync_result_details
        attributes["details"] = nil if attributes["result"] == "true"
      end
    end
  end
end
