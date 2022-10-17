module Providers
  module ApplicationMeritsTask
    class ClientOfferedUndertakingsForm < BaseForm
      form_for ::ApplicationMeritsTask::Undertaking

      attr_accessor :offered, :additional_information

      validate :offered_presence
      validates :additional_information, presence: true, if: :requires_additional_information?

      def save
        additional_information&.clear if offered?
        super
      end

    private

      def offered_presence
        errors.add(:offered, :blank) if offered.to_s.blank?
      end

      def offered?
        offered.to_s == "true"
      end

      def requires_additional_information?
        offered.to_s == "false"
      end
    end
  end
end
