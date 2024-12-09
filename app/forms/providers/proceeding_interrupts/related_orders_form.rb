module Providers
  module ProceedingInterrupts
    class RelatedOrdersForm < BaseForm
      form_for Proceeding

      ORDER_TYPES = %i[
        care
        supervision
        secure_accommodation
        placement
        adoption
        emergency_protection
        child_assessment
        parenting
        child_safety
      ].freeze

      attr_accessor :none_selected, :related_orders

      validate :validate_any_checkbox_checked, unless: :draft?
      validate :validate_none_and_another_checkbox_not_both_checked, unless: :draft?

      def exclude_from_model
        [:none_selected]
      end

      def save_as_draft
        @draft = true
        save!
      end

    private

      def any_checkbox_checked?
        none_selected? || related_orders.flatten.compact_blank.any?
      end

      def none_and_another_checkbox_checked?
        none_selected? && related_orders.flatten.compact_blank.any?
      end

      def none_selected?
        none_selected == "true"
      end

      def validate_any_checkbox_checked
        errors.add :related_orders, error_message_for_none_selected unless any_checkbox_checked?
      end

      def validate_none_and_another_checkbox_not_both_checked
        errors.add :related_orders, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
      end

      def error_message_for_none_selected
        I18n.t("activemodel.errors.models.related_orders.attributes.base.none_selected")
      end

      def error_message_for_none_and_another_option_selected
        I18n.t("activemodel.errors.models.related_orders.attributes.base.none_and_another_option_selected")
      end
    end
  end
end
