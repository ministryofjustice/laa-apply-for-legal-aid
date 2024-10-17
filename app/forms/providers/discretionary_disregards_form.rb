module Providers
  class DiscretionaryDisregardsForm < BaseForm
    form_for DiscretionaryDisregards
    include DisregardsHandling

    SINGLE_VALUE_ATTRIBUTES = %i[
      backdated_benefits
      compensation_for_personal_harm
      criminal_injuries_compensation
      grenfell_tower_fire_victims
      london_emergencies_trust
      national_emergencies_trust
      loss_or_harm_relating_to_this_application
      victims_of_overseas_terrorism_compensation
      we_love_manchester_emergency_fund
    ].freeze

    CHECK_BOXES_ATTRIBUTES = (SINGLE_VALUE_ATTRIBUTES.map(&:to_sym) + %i[none_selected]).freeze

    attr_accessor(*CHECK_BOXES_ATTRIBUTES)

  private

    def checkbox_hash
      CHECK_BOXES_ATTRIBUTES.index_with { |attribute| __send__(attribute) }
    end

    def validate_any_checkbox_checked
      errors.add :discretionary_disregards, error_message_for_none_selected unless any_checkbox_checked?
    end

    def validate_no_disregard_and_another_checkbox_not_both_checked
      errors.add :discretionary_disregards, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
    end

    def error_message_for_none_selected
      I18n.t("activemodel.errors.models.discretionary_disregards.attributes.base.#{error_key('none_selected')}")
    end

    def error_message_for_none_and_another_option_selected
      I18n.t("activemodel.errors.models.discretionary_disregards.attributes.base.none_and_another_option_selected")
    end
  end
end
