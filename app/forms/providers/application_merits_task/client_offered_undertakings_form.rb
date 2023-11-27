module Providers
  module ApplicationMeritsTask
    class ClientOfferedUndertakingsForm < BaseForm
      form_for ::ApplicationMeritsTask::Undertaking

      attr_accessor :offered, :additional_information, :additional_information_true, :additional_information_false

      validates :offered, inclusion: { in: %w[true false] }
      validates :additional_information_true, presence: true, if: :requires_yes_additional_information?
      validates :additional_information_false, presence: true, if: :requires_no_additional_information?

      def initialize(*args)
        super
        extrapolate_additional_information
      end

      def save
        attributes[:additional_information] = requires_yes_additional_information? ? additional_information_true : additional_information_false
        super
      end
      alias_method :save!, :save

    private

      def requires_yes_additional_information?
        offered.to_s == "true"
      end

      def requires_no_additional_information?
        offered.to_s == "false"
      end

      def extrapolate_additional_information
        return unless %w[true false].include?(offered.to_s)
        return unless additional_information_expandable?

        field = "additional_information_#{offered}"
        __send__("#{field}=", additional_information)
        attributes[field] = additional_information
      end

      def additional_information_expandable?
        additional_information.present? && __send__("additional_information_#{offered}").nil?
      end

      def exclude_from_model
        %i[additional_information_true additional_information_false]
      end
    end
  end
end
