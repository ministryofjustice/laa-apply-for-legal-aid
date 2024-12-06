module Providers
  module ProceedingInterrupts
    class RelatedOrdersForm
      include ActiveModel::Model

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

      attr_reader :selected_orders
      attr_accessor :none_selected

      validate :validate_any_checkbox_checked, unless: :draft?
      validate :validate_none_and_another_checkbox_not_both_checked, unless: :draft?

      def selected_orders=(orders)
        @selected_orders = orders.flatten.compact_blank
      end

      def save_as_draft
        @draft = true
      end

      def draft?
        @draft
      end

    private

      def any_checkbox_checked?
        none_selected? || selected_orders.any?
      end

      def none_and_another_checkbox_checked?
        none_selected? && selected_orders.any?
      end

      def none_selected?
        none_selected == "true"
      end

      def validate_any_checkbox_checked
        errors.add :selected_orders, error_message_for_none_selected unless any_checkbox_checked?
      end

      def validate_none_and_another_checkbox_not_both_checked
        errors.add :selected_orders, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
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
