module Providers
  class PolicyDisregardsForm < BaseForm
    form_for PolicyDisregards

    SINGLE_VALUE_ATTRIBUTES = %i[
      england_infected_blood_support
      vaccine_damage_payments
      variant_creutzfeldt_jakob_disease
      criminal_injuries_compensation_scheme
      national_emergencies_trust
      we_love_manchester_emergency_fund
      london_emergencies_trust
    ].freeze

    CHECK_BOXES_ATTRIBUTES = (SINGLE_VALUE_ATTRIBUTES.map(&:to_sym) + %i[none_selected]).freeze

    attr_accessor(*CHECK_BOXES_ATTRIBUTES)

    validate :any_checkbox_checked_or_draft

    def any_checkbox_checked?
      CHECK_BOXES_ATTRIBUTES.map { |attribute| __send__(attribute) }.any?(&:present?)
    end

    def has_partner_with_no_contrary_interest?
      model.legal_aid_application.applicant&.has_partner_with_no_contrary_interest?
    end

  private

    def any_checkbox_checked_or_draft
      errors.add SINGLE_VALUE_ATTRIBUTES.first.to_sym, error_message_for_none_selected unless any_checkbox_checked? || draft?
    end

    def error_message_for_none_selected
      I18n.t("activemodel.errors.models.policy_disregards.attributes.base.#{error_key('none_selected')}")
    end
  end
end
