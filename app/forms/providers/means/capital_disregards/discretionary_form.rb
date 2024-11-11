module Providers
  module Means
    module CapitalDisregards
      class DiscretionaryForm
        include ActiveModel::Model

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

        attr_reader :discretionary_capital_disregards
        attr_accessor :legal_aid_application, :none_selected

        validate :validate_any_checkbox_checked, unless: :draft?
        validate :validate_none_and_another_checkbox_not_both_checked, unless: :draft?

        def initialize(params = {})
          self.legal_aid_application = params.delete(:model)
          self.discretionary_capital_disregards = params["discretionary_capital_disregards"] || existing_discretionary_capital_disregards

          super
        end

        def discretionary_capital_disregards=(names)
          @discretionary_capital_disregards = [names].flatten.compact_blank
        end

        def save
          return false unless valid?

          ApplicationRecord.transaction do
            synchronize_discretionary_capital_disregards
          end
        end
        alias_method :save!, :save

        def save_as_draft
          @draft = true
          save!
        end

        def draft?
          @draft
        end

      private

        def synchronize_discretionary_capital_disregards
          existing = existing_discretionary_capital_disregards

          keep = discretionary_capital_disregards.each_with_object([]) do |disregard_type, arr|
            next unless DISREGARD_TYPES.include?(disregard_type.to_sym)

            add_discretionary_capital_disregard!(disregard_type) if existing.exclude?(disregard_type)
            arr.append(disregard_type)
          end

          destroy_all_discretionary_capital_disregards(except: keep)
        end

        def add_discretionary_capital_disregard!(disregard_type)
          legal_aid_application.capital_disregards.create!(name: disregard_type, mandatory: false)
        end

        def destroy_all_discretionary_capital_disregards(except:)
          legal_aid_application
            .discretionary_capital_disregards
            .where.not(name: except)
            .destroy_all
        end

        def existing_discretionary_capital_disregards
          legal_aid_application.discretionary_capital_disregards.pluck(:name)
        end

        def any_checkbox_checked?
          none_selected? || discretionary_capital_disregards.any?
        end

        def none_and_another_checkbox_checked?
          none_selected? && discretionary_capital_disregards.any?
        end

        def none_selected?
          none_selected == "true"
        end

        def validate_any_checkbox_checked
          errors.add :discretionary_disregards, error_message_for_none_selected unless any_checkbox_checked?
        end

        def validate_none_and_another_checkbox_not_both_checked
          errors.add :discretionary_disregards, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
        end

        def error_message_for_none_selected
          I18n.t("activemodel.errors.models.discretionary_capital_disregards.attributes.base.#{error_key('none_selected')}")
        end

        def error_message_for_none_and_another_option_selected
          I18n.t("activemodel.errors.models.discretionary_capital_disregards.attributes.base.#{error_key('none_and_another_option_selected')}")
        end

        def error_key(key_name)
          return "#{key_name}_with_partner" if legal_aid_application&.applicant&.has_partner_with_no_contrary_interest?

          key_name
        end
      end
    end
  end
end
