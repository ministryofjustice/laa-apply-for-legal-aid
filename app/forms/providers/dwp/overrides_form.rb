module Providers
  module DWP
    class OverridesForm < BaseForm
      form_for Partner

      RESPONSE_ATTRIBUTES = %w[
        benefit_received
        joint_benefit_with_partner
        no_benefit_received
      ].freeze

      attr_accessor :confirm_dwp_result

      validate :response_present?

      def correct_dwp_result?
        attributes["confirm_dwp_result"] == "no_benefit_received"
      end

      def confirm_receipt_of_benefit?
        attributes["confirm_dwp_result"] != "no_benefit_received"
      end

      def receives_joint_benefit?
        attributes["confirm_dwp_result"] == "joint_benefit_with_partner"
      end

      def response_present?
        return false if draft?

        if confirm_dwp_result.nil? || RESPONSE_ATTRIBUTES.exclude?(confirm_dwp_result)
          errors.add(:confirm_dwp_result, I18n.t("providers.confirm_dwp_non_passported_applications.show.error"))
        end
      end
    end
  end
end
