module Providers
  class ConfirmDWPNonPassportedApplicationsForm < BaseForm
    form_for LegalAidApplication

    RESPONSE_ATTRIBUTES = %w[
      dwp_correct
      joint_with_partner_false
      joint_with_partner_true
    ].freeze

    attr_accessor :confirm_dwp_result

    validates :confirm_dwp_result, inclusion: { in: RESPONSE_ATTRIBUTES }

    def correct_dwp_result?
      attributes["confirm_dwp_result"] == "dwp_correct"
    end

    def receives_joint_benefit?
      attributes["confirm_dwp_result"] == "joint_with_partner_true"
    end
  end
end
