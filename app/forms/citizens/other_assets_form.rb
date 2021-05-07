module Citizens
  class OtherAssetsForm
    include BaseForm

    form_for OtherAssetsDeclaration

    VALUABLE_ITEMS_VALUE_ATTRIBUTE = %i[valuable_items_value].freeze

    SINGLE_VALUE_ATTRIBUTES = %i[
      timeshare_property_value
      land_value
      inherited_assets_value
      money_owed_value
      trust_value
    ].freeze

    SECOND_HOME_ATTRIBUTES = %i[
      second_home_value
      second_home_mortgage
      second_home_percentage
    ].freeze

    OTHER_CHECKBOXES = %i[check_box_second_home check_box_valuable_items_value none_selected].freeze

    INDIVIDUALLY_VALIDATED = %i[second_home_percentage valuable_items_value].freeze

    ALL_ATTRIBUTES = (SECOND_HOME_ATTRIBUTES + SINGLE_VALUE_ATTRIBUTES + VALUABLE_ITEMS_VALUE_ATTRIBUTE).freeze

    CHECK_BOXES_ATTRIBUTES = (SINGLE_VALUE_ATTRIBUTES.map { |attribute| "check_box_#{attribute}".to_sym } + OTHER_CHECKBOXES).freeze

    validates(:second_home_percentage, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true)
    validates(:valuable_items_value, currency: { greater_than_or_equal_to: 500 }, allow_blank: true)
    validates(*SECOND_HOME_ATTRIBUTES, presence: true, if: proc { |form| form.check_box_second_home.present? })
    validates(*ALL_ATTRIBUTES - INDIVIDUALLY_VALIDATED, allow_blank: true, currency: { greater_than_or_equal_to: 0 })
    validates(*VALUABLE_ITEMS_VALUE_ATTRIBUTE, presence: true, if: proc { |form| form.__send__(:check_box_valuable_items_value).present? })

    SINGLE_VALUE_ATTRIBUTES.each do |attribute|
      check_box_attribute = "check_box_#{attribute}".to_sym
      validates attribute, presence: true, if: proc { |form| form.__send__(check_box_attribute).present? }
    end

    attr_accessor(*ALL_ATTRIBUTES)
    attr_accessor(*CHECK_BOXES_ATTRIBUTES)
    attr_accessor :journey

    before_validation :empty_unchecked_values

    validate :all_second_home_values_present_if_any_are_present
    validate :any_checkbox_checked_or_draft

    def second_home_checkbox_status
      any_second_home_value_present? ? 'checked' : nil
    end

    def any_second_home_value_present?
      present_and_not_zero?(@second_home_value) ||
        present_and_not_zero?(@second_home_mortgage) ||
        present_and_not_zero?(@second_home_percentage)
    end

    def exclude_from_model
      CHECK_BOXES_ATTRIBUTES + [:journey] - [:none_selected]
    end

    def attributes_to_clean
      ALL_ATTRIBUTES - [:second_home_percentage]
    end

    def any_checkbox_checked?
      CHECK_BOXES_ATTRIBUTES.map { |attribute| __send__(attribute) }.any?(&:present?)
    end

    private

    def empty_unchecked_values
      (SINGLE_VALUE_ATTRIBUTES + VALUABLE_ITEMS_VALUE_ATTRIBUTE).each do |attribute|
        check_box_attribute = "check_box_#{attribute}".to_sym
        if __send__(check_box_attribute).blank?
          attributes[attribute] = nil
          instance_variable_set(:"@#{attribute}", nil)
        end
      end

      nullify_second_home_attrs if @check_box_second_home.blank?
    end

    def nullify_second_home_attrs
      attributes[:second_home_value] = nil
      attributes[:second_home_mortgage] = nil
      attributes[:second_home_percentage] = nil
      @second_home_value = nil
      @second_home_mortgage = nil
      @second_home_percentage = nil
    end

    def all_second_home_values_present_if_any_are_present
      return unless any_second_home_value_present?

      SECOND_HOME_ATTRIBUTES.each do |attr|
        errors.add(attr, :blank) if __send__(attr).blank? & errors[attr].empty?
      end
    end

    def base_checkbox
      CHECK_BOXES_ATTRIBUTES.first
    end

    def any_checkbox_checked_or_draft
      errors.add base_checkbox.to_sym, error_message_for_none_selected unless any_checkbox_checked? || draft?
    end

    def error_message_for_none_selected
      I18n.t("activemodel.errors.models.other_assets_declaration.attributes.base.#{journey}.none_selected")
    end

    def present_and_not_zero?(attr)
      attr.present? && !zero_string?(attr)
    end

    def zero_string?(attr)
      /\A0+\z/.match? attr.to_s.tr(' ,.', '')
    end
  end
end
