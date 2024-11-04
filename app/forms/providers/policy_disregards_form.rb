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

    validate :validate_any_checkbox_checked, unless: :draft?
    validate :validate_none_of_these_and_another_checkbox_not_both_checked, unless: :draft?

    def has_partner_with_no_contrary_interest?
      model.legal_aid_application.applicant&.has_partner_with_no_contrary_interest?
    end

  private

    def any_checkbox_checked?
      checkbox_hash.values.any?(&:present?)
    end

    def checkbox_hash
      CHECK_BOXES_ATTRIBUTES.index_with { |attribute| __send__(attribute) }
    end

    def none_and_another_checkbox_checked?
      checkbox_hash[:none_selected].present? && checkbox_hash.except(:none_selected).values.any?(&:present?)
    end

    def validate_any_checkbox_checked
      errors.add SINGLE_VALUE_ATTRIBUTES.first.to_sym, error_message_for_none_selected unless any_checkbox_checked?
    end

    def validate_none_of_these_and_another_checkbox_not_both_checked
      errors.add SINGLE_VALUE_ATTRIBUTES.first.to_sym, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
    end

    def error_message_for_none_selected
      I18n.t("activemodel.errors.models.policy_disregards.attributes.base.#{error_key('none_selected')}")
    end

    def error_message_for_none_and_another_option_selected
      I18n.t("activemodel.errors.models.policy_disregards.attributes.base.none_and_another_option_selected")
    end
  end
end
