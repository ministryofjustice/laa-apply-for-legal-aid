module Providers
  module Means
    module CapitalDisregards
      class MandatoryForm < BaseForm
        form_for LegalAidApplication

        MANDATORY_DISREGARD_TYPES = %i[
          backdated_benefits
          backdated_community_care
          budgeting_advances
          compensation_miscarriage_of_justice
          government_cost_of_living
          independent_living_fund
          infected_blood_support_scheme
          modern_slavery_victim_care
          payment_on_account_of_benefit
          historical_child_abuse
          social_fund
          vaccine_damage
          variant_creutzfeldt_jakob_disease
          welsh_independent_living_grant
          windrush_compensation_scheme
        ].freeze

        attr_accessor :mandatory_capital_disregards, :none_selected

        validate :validate_any_checkbox_checked, unless: :draft?
        validate :validate_none_selected_and_another_checkbox_not_both_checked, unless: :draft?

        def save
          return false unless valid?

          # TODO: don't destroy all, compare with existing disregards
          model.capital_disregards.where(mandatory: true).destroy_all
          mandatory_capital_disregards&.each { |disregard| model.capital_disregards.create!(name: disregard, mandatory: true) }
        end
        alias_method :save!, :save

        def disregard_types
          MANDATORY_DISREGARD_TYPES
        end

      private

        def any_checkbox_checked?
          none_selected == "true" || mandatory_capital_disregards
        end

        def none_and_another_checkbox_checked?
          none_selected == "true" && mandatory_capital_disregards
        end

        def validate_any_checkbox_checked
          errors.add :mandatory_capital_disregards, error_message_for_none_selected unless any_checkbox_checked?
        end

        def validate_none_selected_and_another_checkbox_not_both_checked
          errors.add :mandatory_capital_disregards, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
        end

        def error_message_for_none_selected
          I18n.t("activemodel.errors.models.mandatory_capital_disregards.attributes.base.#{error_key('none_selected')}")
        end

        def error_message_for_none_and_another_option_selected
          I18n.t("activemodel.errors.models.mandatory_capital_disregards.attributes.base.none_and_another_option_selected")
        end
      end
    end
  end
end
