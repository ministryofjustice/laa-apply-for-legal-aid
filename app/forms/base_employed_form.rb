class BaseEmployedForm < BaseForm
  EMPLOYMENT_TYPES = %i[employed self_employed armed_forces].freeze
  CHECK_BOXES_ATTRIBUTES = (EMPLOYMENT_TYPES + [:none_selected]).freeze

  attr_accessor(*CHECK_BOXES_ATTRIBUTES)

  validate :validate_any_checkbox_checked, unless: :draft?
  validate :validate_none_and_another_checkbox_not_both_checked, unless: :draft?

private

  def initialize(params = {})
    EMPLOYMENT_TYPES.each do |employment_type|
      send("#{employment_type}=", params[:model].send(employment_type))
    end

    super
  end

  def any_checkbox_checked?
    checkbox_hash.values.any?(&:present?)
  end

  def none_and_another_checkbox_checked?
    checkbox_hash[:none_selected].present? && checkbox_hash.except(:none_selected).values.any?(&:present?)
  end

  def checkbox_hash
    CHECK_BOXES_ATTRIBUTES.index_with { |attribute| __send__(attribute) }
  end

  def exclude_from_model
    [:none_selected]
  end

  def validate_none_and_another_checkbox_not_both_checked
    errors.add EMPLOYMENT_TYPES.first.to_sym, error_message_for_none_and_another_option_selected if none_and_another_checkbox_checked?
  end

  def validate_any_checkbox_checked
    errors.add EMPLOYMENT_TYPES.first.to_sym, error_message_for_none_selected unless any_checkbox_checked?
  end

  def clean_attributes(hash)
    hash.each { |k, v| hash[k] = "false" if v == "" }
  end
end
