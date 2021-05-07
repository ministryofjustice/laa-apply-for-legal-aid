module Providers
  class PolicyDisregardsForm
    include BaseForm

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

    private

    def any_checkbox_checked_or_draft
      errors.add SINGLE_VALUE_ATTRIBUTES.first.to_sym, error_message_for_none_selected unless any_checkbox_checked? || draft?
    end

    def error_message_for_none_selected
      I18n.t('activemodel.errors.models.policy_disregards.attributes.base.none_selected')
    end
  end
end
