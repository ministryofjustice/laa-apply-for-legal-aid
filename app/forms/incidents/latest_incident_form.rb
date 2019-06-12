module Incidents
  class LatestIncidentForm
    include BaseForm
    form_for Incident

    attr_accessor :occurred_year, :occurred_month, :occurred_day, :details
    attr_writer :occurred_on

    validates :occurred_on, presence: true, unless: :draft_and_not_partially_complete_date?
    validates :occurred_on, date: { not_in_the_future: true }, allow_nil: true
    validates :details, presence: true, unless: :draft?

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: date_fields.fields,
        model_attributes: date_fields.model_attributes
      )
    end

    def occurred_on
      return @occurred_on if @occurred_on.present?
      return if date_fields.blank?
      return :invalid if date_fields.partially_complete? || date_fields.form_date_invalid?

      @occurred_on = attributes[:occurred_on] = date_fields.form_date
    end

    private

    def exclude_from_model
      date_fields.fields
    end

    def draft_and_not_partially_complete_date?
      draft? && !date_fields.partially_complete?
    end

    def date_fields
      @date_fields ||= DateFieldBuilder.new(
        form: self,
        model: model,
        method: :occurred_on,
        prefix: :occurred_
      )
    end
  end
end
