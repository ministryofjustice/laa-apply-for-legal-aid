module Providers
  module ProceedingMeritsTask
    class OpponentsApplicationForm < BaseForm
      form_for ::ProceedingMeritsTask::ProhibitedSteps

      attr_accessor :opponents_application, :details, :proceeding_id

      validates :opponents_application, inclusion: { in: %w[true false] }
      validates :details, presence: true, if: :requires_details?
      before_validation :clear_details, if: :opponents_application?

    private

      def clear_details
        attributes["details"] = nil
      end

      def opponents_application?
        opponents_application.to_s == "true"
      end

      def requires_details?
        opponents_application.to_s == "false"
      end
    end
  end
end
