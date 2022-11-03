module Providers
  module ProceedingMeritsTask
    class OpponentsApplicationForm < BaseForm
      form_for ::ProceedingMeritsTask::OpponentsApplication

      attr_accessor :has_opponents_application, :reason_for_applying, :proceeding_id

      validates :has_opponents_application, inclusion: { in: %w[true false] }
      validates :reason_for_applying, presence: true, if: :requires_reason_for_applying?
      before_validation :clear_reason_for_applying, if: :has_opponents_application?

    private

      def clear_reason_for_applying
        attributes["reason_for_applying"] = nil
      end

      def has_opponents_application?
        has_opponents_application.to_s == "true"
      end

      def requires_reason_for_applying?
        has_opponents_application.to_s == "false"
      end
    end
  end
end
