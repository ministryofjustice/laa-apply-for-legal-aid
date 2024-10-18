module Providers
  class PolicyDisregardsForm < BaseForm
    form_for PolicyDisregards

    MANDATORY_DISREGARDS_ATTRIBUTES = %i[
      backdated_benefits
      backdated_community_care
      budgeting_advances
      compensation_miscarriage_of_justice
      government_cost_of_living
      independent_living_fund
      infected_blood_support
      modern_slavery
      account_of_benefit
      historical_child_abuse
      social_fund
      vaccine_damage
      variant_creutzfeldt_jakob_disease
      welsh_independent_living_grant
      windrush_compensation_scheme
    ].freeze

    LEGACY_DISREGARDS_ATTRIBUTES = %i[
      england_infected_blood_support
      vaccine_damage_payments
      variant_creutzfeldt_jakob_disease
      criminal_injuries_compensation_scheme
      national_emergencies_trust
      we_love_manchester_emergency_fund
      london_emergencies_trust
    ].freeze

    def self.check_box_attributes
      attributes = Setting.means_test_review_a? ? MANDATORY_DISREGARDS_ATTRIBUTES : LEGACY_DISREGARDS_ATTRIBUTES
      (attributes.map(&:to_sym) + %i[none_selected]).freeze
    end

    attr_accessor(*check_box_attributes)

    validate :validate_any_checkbox_checked, unless: :draft?
    validate :validate_no_account_and_another_checkbox_not_both_checked, unless: :draft?

    def has_partner_with_no_contrary_interest?
      model.legal_aid_application.applicant&.has_partner_with_no_contrary_interest?
    end

  private

    def any_checkbox_checked?
      checkbox_hash.values.any?(&:present?)
    end

    def checkbox_hash
      check_box_attributes.index_with { |attribute| __send__(attribute) }
    end

    def check_box_attributes
      self.class.check_box_attributes
    end

    def none_and_another_checkbox_checked?
      checkbox_hash[:none_selected].present? && checkbox_hash.except(:none_selected).values.any?(&:present?)
    end

    def validate_any_checkbox_checked
      errors.add check_box_attributes.first.to_sym, error_message_for_none_selected unless any_checkbox_checked?
    end

    def validate_no_account_and_another_checkbox_not_both_checked
      errors.add check_box_attributes.first.to_sym, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
    end

    def error_message_for_none_selected
      I18n.t("activemodel.errors.models.policy_disregards.attributes.base.#{error_key('none_selected')}")
    end

    def error_message_for_none_and_another_option_selected
      I18n.t("activemodel.errors.models.policy_disregards.attributes.base.none_and_another_option_selected")
    end
  end
end
