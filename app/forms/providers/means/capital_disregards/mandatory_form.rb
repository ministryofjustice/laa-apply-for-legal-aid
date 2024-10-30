module Providers
  module Means
    module CapitalDisregards
      class MandatoryForm
        include ActiveModel::Model

        DISREGARD_TYPES = %i[
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

        attr_reader :mandatory_capital_disregards
        attr_accessor :legal_aid_application, :none_selected

        validate :validate_any_checkbox_checked, unless: :draft?
        validate :validate_none_selected_and_another_checkbox_not_both_checked, unless: :draft?

        def initialize(params = {})
          self.legal_aid_application = params.delete(:model)
          self.mandatory_capital_disregards = params["mandatory_capital_disregards"] || existing_mandatory_disregards

          super
        end

        def mandatory_capital_disregards=(names)
          @mandatory_capital_disregards = [names].flatten.compact_blank
        end

        def save_as_draft
          @draft = true
          save!
        end

        def draft?
          @draft
        end

        def save
          return false unless valid?

          destroy_previous_disregards!
          create_new_disregards!
        end
        alias_method :save!, :save

      private

        # create new records if they don't already exist
        def create_new_disregards!
          return unless mandatory_capital_disregards

          mandatory_capital_disregards&.reject { |disregard|
            existing_mandatory_disregards.include?(disregard)
          }&.each { |disregard| legal_aid_application.capital_disregards.create!(name: disregard, mandatory: true) }
        end

        # destroy only the records which already exist but aren't selected
        def destroy_previous_disregards!
          legal_aid_application.mandatory_capital_disregards&.where&.not(name: mandatory_capital_disregards)&.destroy_all
        end

        def existing_mandatory_disregards
          legal_aid_application.mandatory_capital_disregards.pluck(:name)
        end

        def none_selected?
          none_selected == "true"
        end

        def any_checkbox_checked?
          none_selected? || mandatory_capital_disregards.any?
        end

        def none_and_another_checkbox_checked?
          none_selected? && mandatory_capital_disregards.any?
        end

        def validate_any_checkbox_checked
          errors.add :mandatory_capital_disregards, error_message_for_none_selected unless any_checkbox_checked?
        end

        def validate_none_selected_and_another_checkbox_not_both_checked
          errors.add :mandatory_capital_disregards, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
        end

        def error_message_for_none_selected
          I18n.t("activemodel.errors.models.mandatory_capital_disregards.attributes.base.none_selected")
        end

        def error_message_for_none_and_another_option_selected
          I18n.t("activemodel.errors.models.mandatory_capital_disregards.attributes.base.#{error_key('none_and_another_option_selected')}")
        end

        def error_key(key_name)
          return "#{key_name}_with_partner" if legal_aid_application&.applicant&.has_partner_with_no_contrary_interest?

          key_name
        end
      end
    end
  end
end
