module Providers
  module ApplicationMeritsTask
    class ClientDenialOfAllegationForm < BaseForm
      form_for ::ApplicationMeritsTask::Allegation

      attr_accessor :denies_all, :additional_information

      validate :denies_all_presence
      validates :additional_information, presence: true, if: :requires_additional_information?

      def save
        additional_information&.clear if denies_all?
        super
      end
      alias_method :save!, :save

    private

      def denies_all_presence
        errors.add(:denies_all, :blank) if denies_all.to_s.blank?
      end

      def denies_all?
        denies_all.to_s == "true"
      end

      def requires_additional_information?
        denies_all.to_s == "false"
      end
    end
  end
end
