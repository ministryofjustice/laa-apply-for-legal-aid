module Providers
  module ProceedingMeritsTask
    class ProhibitedStepsForm < BaseForm
      form_for ::ProceedingMeritsTask::ProhibitedSteps

      attr_accessor :uk_removal, :details, :proceeding_id

      before_validation :clear_details, if: :uk_removal?

      validates :uk_removal, inclusion: { in: %w[true false] }
      validates :details, presence: true, if: :requires_details?

    private

      def clear_details
        attributes["details"] = nil
      end

      def uk_removal?
        uk_removal.to_s == "true"
      end

      def requires_details?
        uk_removal.to_s == "false"
      end
    end
  end
end
