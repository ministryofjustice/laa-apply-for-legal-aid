module Incidents
  class ToldOnForm
    include BaseForm
    form_for ApplicationMeritsTask::Incident

    attr_accessor :told_on_1i, :told_on_2i, :told_on_3i
    attr_writer :told_on

    attr_accessor :occurred_on_1i, :occurred_on_2i, :occurred_on_3i
    attr_writer :occurred_on

    validates :told_on, presence: true, unless: :draft_and_not_partially_complete_told_on_date?
    validates :told_on, date: { not_in_the_future: true }, allow_nil: true

    validates :occurred_on, presence: true, unless: :draft_and_not_partially_complete_occurred_on_date?
    validates :occurred_on, date: { not_in_the_future: true }, allow_nil: true

    validate :occurred_on_before_told_on

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: (told_on_date_fields.fields + occurred_on_date_fields.fields),
        model_attributes:
        [
          told_on_date_fields.model_attributes,
          occurred_on_date_fields.model_attributes
        ].compact.reduce(&:merge)
      )
    end

    def told_on
      return @told_on if @told_on.present?
      return if told_on_date_fields.blank?
      return told_on_date_fields.input_field_values if told_on_incomplete?

      @told_on = attributes[:told_on] = told_on_date_fields.form_date
    end

    def occurred_on
      return @occurred_on if @occurred_on.present?
      return if occurred_on_date_fields.blank?
      return occurred_on_date_fields.input_field_values if occurred_on_incomplete?

      @occurred_on = attributes[:occurred_on] = occurred_on_date_fields.form_date
    end

    private

    def told_on_incomplete?
      told_on_date_fields.partially_complete? || told_on_date_fields.form_date_invalid?
    end

    def occurred_on_incomplete?
      occurred_on_date_fields.partially_complete? || occurred_on_date_fields.form_date_invalid?
    end

    def occurred_on_before_told_on
      return if occurred_on.blank? || told_on.blank?
      return if occurred_on_incomplete? || told_on_incomplete?

      errors.add(:occurred_on, :invalid_timeline) if told_on < occurred_on
    end

    def exclude_from_model
      (told_on_date_fields.fields + occurred_on_date_fields.fields)
    end

    def draft_and_not_partially_complete_told_on_date?
      draft? && !told_on_date_fields.partially_complete?
    end

    def draft_and_not_partially_complete_occurred_on_date?
      draft? && !occurred_on_date_fields.partially_complete?
    end

    def told_on_date_fields
      @told_on_date_fields ||= DateFieldBuilder.new(
        form: self,
        model: model,
        method: :told_on,
        prefix: :told_on_,
        suffix: :gov_uk
      )
    end

    def occurred_on_date_fields
      @occurred_on_date_fields ||= DateFieldBuilder.new(
        form: self,
        model: model,
        method: :occurred_on,
        prefix: :occurred_on_,
        suffix: :gov_uk
      )
    end
  end
end
