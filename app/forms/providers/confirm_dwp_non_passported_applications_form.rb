module Providers
  class ConfirmDWPNonPassportedApplicationsForm < BaseForm
    form_for Partner

    RESPONSE_ATTRIBUTES = %w[
      dwp_correct
      joint_with_partner_false
      joint_with_partner_true
    ].freeze

    attr_accessor :confirm_dwp_result

    validate :response_present?

    def correct_dwp_result?
      attributes["confirm_dwp_result"] == "dwp_correct"
    end

    def receives_joint_benefit?
      attributes["confirm_dwp_result"] == "joint_with_partner_true"
    end

    def response_present?
      return if draft?

      if confirm_dwp_result.nil? || RESPONSE_ATTRIBUTES.exclude?(confirm_dwp_result)
        errors.add(:confirm_dwp_result, I18n.t("providers.confirm_dwp_non_passported_applications.show.error"))
      end
    end
  end
end
