module Citizens
  class OtherAssetsForm
    include BaseForm

    form_for OtherAssetsDeclaration

    SINGLE_VALUE_ATTRIBUTES = %i[
      timeshare_value
      land_value
      jewellery_value
      vehicle_value
      classic_car_value
      money_assets_value
      money_owed_value
      trust_value
    ].freeze

    SECOND_HOME_ATTRIBUTES = %i[
      second_home_value
      second_home_mortgage
      second_home_percentage
    ].freeze

    ALL_ATTRIBUTES = (SECOND_HOME_ATTRIBUTES + SINGLE_VALUE_ATTRIBUTES).freeze

    CHECK_BOXES_ATTRIBUTES = (SINGLE_VALUE_ATTRIBUTES.map { |attribute| "check_box_#{attribute}".to_sym } + [:check_box_second_home]).freeze

    validates(*SECOND_HOME_ATTRIBUTES, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true)
    validates(*SECOND_HOME_ATTRIBUTES, presence: true, if: proc { |form| form.check_box_second_home.present? })

    SINGLE_VALUE_ATTRIBUTES.each do |attribute|
      check_box_attribute = "check_box_#{attribute}".to_sym
      validates attribute, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
      validates attribute, presence: true, if: proc { |form| form.__send__(check_box_attribute).present? }
    end

    attr_accessor(*ALL_ATTRIBUTES)
    attr_accessor(*CHECK_BOXES_ATTRIBUTES)
    attr_accessor :check_box_second_home

    before_validation :normalize_amounts, :empty_unchecked_values

    validate :all_second_home_values_present_if_any_are_present

    def second_home_checkbox_status
      any_second_home_value_present? ? 'checked' : nil
    end

    def any_second_home_value_present?
      present_and_not_zero?(@second_home_value) ||
        present_and_not_zero?(@second_home_mortgage) ||
        present_and_not_zero?(@second_home_percentage)
    end

    def exclude_from_model
      CHECK_BOXES_ATTRIBUTES
    end

    private

    def empty_unchecked_values
      SINGLE_VALUE_ATTRIBUTES.each do |attribute|
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

    def normalize_amounts
      ALL_ATTRIBUTES
        .map { |attribute| __send__(attribute) }
        .compact
        .each { |value| value.delete!(',') }
    end

    def all_second_home_values_present_if_any_are_present
      return unless any_second_home_value_present?

      SECOND_HOME_ATTRIBUTES.each do |attr|
        errors.add(attr, :blank) if __send__(attr).blank? & errors[attr].empty?
      end
    end

    def present_and_not_zero?(attr)
      attr.present? && !zero_string?(attr)
    end

    def zero_string?(attr)
      /\A0+\z/.match? attr.to_s.tr(' ,.', '')
    end
  end
end
