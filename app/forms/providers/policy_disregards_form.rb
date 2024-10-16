module Providers
  class PolicyDisregardsForm < BaseForm
    form_for PolicyDisregards

    SINGLE_VALUE_ATTRIBUTES = %i[
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

    LEGACY_ATTRIBUTES = %i[
      england_infected_blood_support
      vaccine_damage_payments
      variant_creutzfeldt_jakob_disease
      criminal_injuries_compensation_scheme
      national_emergencies_trust
      we_love_manchester_emergency_fund
      london_emergencies_trust
    ].freeze

    CHECK_BOXES_ATTRIBUTES = generate_check_box_attributes

    attr_accessor(*CHECK_BOXES_ATTRIBUTES)

    validate :validate_any_checkbox_checked, unless: :draft?
    validate :validate_no_account_and_another_checkbox_not_both_checked, unless: :draft?

    def initialize(params = {})
      @transaction_type_ids = params["transaction_type_ids"] || existing_transaction_type_ids
      generate_check_box_attributes

      super
    end

    def has_partner_with_no_contrary_interest?
      model.legal_aid_application.applicant&.has_partner_with_no_contrary_interest?
    end

    def generate_check_box_attributes
      attributes = Setting.means_test_review_a? ? SINGLE_VALUE_ATTRIBUTES : LEGACY_ATTRIBUTES
      @check_boxes_attributes = (attributes.map(&:to_sym) + %i[none_selected]).freeze
      attr_accessor(*@check_boxes_attributes)
    end

  private

    def any_checkbox_checked?
      checkbox_hash.values.any?(&:present?)
    end

    def checkbox_hash
      @check_boxes_attributes.index_with { |attribute| __send__(attribute) }
    end

    def none_and_another_checkbox_checked?
      checkbox_hash[:none_selected].present? && checkbox_hash.except(:none_selected).values.any?(&:present?)
    end

    def validate_any_checkbox_checked
      errors.add SINGLE_VALUE_ATTRIBUTES.first.to_sym, error_message_for_none_selected unless any_checkbox_checked?
    end

    def validate_no_account_and_another_checkbox_not_both_checked
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
