module Incidents
  class ToldOnForm < BaseForm
    form_for ApplicationMeritsTask::Incident

    DATE_OPTIONS = {
      date: {
        format: Date::DATE_FORMATS[:date_picker_parse_format],
        strict_pattern: Date::DATE_PATTERNS[:date_picker_strict],
        not_in_the_future: true,
      },
    }.freeze

    attr_accessor :told_on, :occurred_on

    validates :told_on, presence: true, unless: :draft?
    validates :told_on, **DATE_OPTIONS, allow_nil: true

    validates :occurred_on, presence: true, unless: :draft?
    validates :occurred_on, **DATE_OPTIONS, allow_nil: true

    validate :occurred_on_before_told_on, unless: :draft?

  private

    def occurred_on_before_told_on
      return unless date_valid?(:told_on, told_on) && date_valid?(:occurred_on, occurred_on)

      errors.add(:occurred_on, :invalid_timeline) if told_on.to_date < occurred_on.to_date
    end

    # NOTE: explicitly use the validator that is used for the dates attributes themselves to centralise the logic
    # Also, clear the errors after to avoid double error adding (although I am not sure it is a problem but have
    # seen doubled errors in the tests)
    def date_valid?(attribute_name, attribute_value)
      validator = DateValidator.new(attributes: [attribute_name], **DATE_OPTIONS[:date])
      validator.validate_each(self, attribute_name, attribute_value)

      errors[attribute_name].none?
    end
  end
end
