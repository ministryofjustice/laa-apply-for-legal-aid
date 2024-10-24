module Providers
  module Means
    module CapitalDisregards
      class MandatoryDisregardsForm < BaseForm
        form_for LegalAidApplication

        attr_reader :mandatory_capital_disregards, :none_selected

        validate :validate_types

        def validate_types
          errors.add(:mandatory_capital_disregards, :invalid) if mandatory_capital_disregards.nil? && !none_selected
        end

        def save
          return false unless valid?

          # TODO: don't destroy all, compare with existing disregards
          model.capital_disregards.where(mandatory: true).destroy_all
          mandatory_capital_disregards&.each { |disregard| model.capital_disregards.create!(name: disregard, mandatory: true) }
        end
        alias_method :save!, :save

      private

        # def any_checkbox_checked?
        #   checkbox_hash.values.any?(&:present?)
        # end
        #
        # def checkbox_hash
        #   check_box_attributes.index_with { |attribute| __send__(attribute) }
        # end
        #
        # def check_box_attributes
        #   self.class.check_box_attributes
        # end
        #
        # def none_and_another_checkbox_checked?
        #   checkbox_hash[:none_selected].present? && checkbox_hash.except(:none_selected).values.any?(&:present?)
        # end
        #
        # def validate_any_checkbox_checked
        #   errors.add check_box_attributes.first.to_sym, error_message_for_none_selected unless any_checkbox_checked?
        # end
        #
        # def validate_no_account_and_another_checkbox_not_both_checked
        #   errors.add check_box_attributes.first.to_sym, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
        # end

        def error_message_for_none_selected
          I18n.t("activemodel.errors.models.capital_disregards.attributes.base.#{error_key('none_selected')}")
        end

        def error_message_for_none_and_another_option_selected
          I18n.t("activemodel.errors.models.policy_disregards.attributes.base.none_and_another_option_selected")
        end
      end
    end
  end
end
