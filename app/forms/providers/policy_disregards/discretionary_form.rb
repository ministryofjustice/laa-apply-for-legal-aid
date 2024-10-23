module Providers
  module PolicyDisregards
    class DiscretionaryForm < BaseForm
      form_for LegalAidApplication

      DISREGARD_TYPES = %i[
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

      attr_accessor :discretionary_disregards, :none_selected

      validate :validate_any_checkbox_checked, unless: :draft?
      validate :validate_no_account_and_another_checkbox_not_both_checked, unless: :draft?

      def save
        false unless valid?
      end
      alias_method :save!, :save

    private

      def any_checkbox_checked?
        discretionary_disregards.reject { |disregard| disregard == "" }.any? || none_selected == "true"
      end

      def none_and_another_checkbox_checked?
        none_selected == "true" && discretionary_disregards.reject { |disregard| disregard == "" }.any?
      end

      def validate_any_checkbox_checked
        errors.add :discretionary_disregards, error_message_for_none_selected unless any_checkbox_checked?
      end

      def validate_no_account_and_another_checkbox_not_both_checked
        errors.add :discretionary_disregards, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
      end

      def error_message_for_none_selected
        I18n.t("activemodel.errors.models.discretionary_policy_disregards.attributes.base.#{error_key('none_selected')}")
      end

      def error_message_for_none_and_another_option_selected
        I18n.t("activemodel.errors.models.discretionary_policy_disregards.attributes.base.none_and_another_option_selected")
      end
    end
  end
end
