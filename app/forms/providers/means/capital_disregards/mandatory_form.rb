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
          self.mandatory_capital_disregards = params["mandatory_capital_disregards"] || existing_mandatory_capital_disregards

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

          ApplicationRecord.transaction do
            synchronize_mandatory_capital_disregards
          end
        end
        alias_method :save!, :save

      private

        def synchronize_mandatory_capital_disregards
          existing = existing_mandatory_capital_disregards

          keep = mandatory_capital_disregards.each_with_object([]) do |disregard_type, arr|
            next unless DISREGARD_TYPES.include?(disregard_type.to_sym)

            add_mandatory_capital_disregard!(disregard_type) if existing.exclude?(disregard_type)
            arr.append(disregard_type)
          end

          destroy_all_mandatory_capital_disregards(except: keep)
        end

        def add_mandatory_capital_disregard!(disregard_type)
          legal_aid_application.capital_disregards.create!(name: disregard_type, mandatory: true)
        end

        def destroy_all_mandatory_capital_disregards(except:)
          legal_aid_application
            .mandatory_capital_disregards
            .where.not(name: except)
            .destroy_all
        end

        def existing_mandatory_capital_disregards
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
