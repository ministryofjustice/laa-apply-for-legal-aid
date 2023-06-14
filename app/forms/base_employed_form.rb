class BaseEmployedForm < BaseForm
  EMPLOYMENT_TYPES = %i[employed self_employed armed_forces].freeze
  CHECK_BOXES_ATTRIBUTES = (EMPLOYMENT_TYPES + [:none_selected]).freeze

  attr_accessor(*CHECK_BOXES_ATTRIBUTES)

  validate :any_checkbox_checked_or_draft

  def any_checkbox_checked?
    CHECK_BOXES_ATTRIBUTES.map { |attribute| __send__(attribute) }.any?(&:present?)
  end

private

  def exclude_from_model
    [:none_selected]
  end

  def any_checkbox_checked_or_draft
    errors.add EMPLOYMENT_TYPES.first.to_sym, error_message_for_none_selected unless any_checkbox_checked? || draft?
  end

  def clean_attributes(hash)
    hash.each { |k, v| hash[k] = "false" if v == "" }
  end
end
