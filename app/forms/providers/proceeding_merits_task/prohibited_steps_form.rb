module Providers
  module ProceedingMeritsTask
    class ProhibitedStepsForm < BaseForm
      form_for ::ProceedingMeritsTask::ProhibitedSteps

      attr_accessor :uk_removal, :details, :proceeding_id

      validate :uk_removal_presence
      validates :details, presence: true, if: :requires_details?

      def save
        details&.clear if uk_removal?
        super
      end

    private

      def uk_removal_presence
        errors.add(:uk_removal, :blank) if uk_removal.to_s.blank?
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
