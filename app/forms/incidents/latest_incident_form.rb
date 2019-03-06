module Incidents
  class LatestIncidentForm
    include BaseForm

    form_for Incident

    attr_accessor :occurred_year, :occurred_month, :occurred_day, :details
    attr_writer :occurred_on

    validates :details, presence: true, unless: :draft?
    validates :occurred_on, presence: true, unless: :draft_and_not_incomplete_date?
    validates :occurred_on, date: { not_in_the_future: true }, allow_nil: true

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: occurred_on_fields,
        model_attributes: occurred_on_from_model
      )
    end

    def occurred_on
      return @occurred_on if @occurred_on.present?
      return incomplete_date if occurred_on_methods.any?(&:blank?)

      @occurred_on = attributes[:occurred_on] = Date.new(*occurred_on_methods.map(&:to_i))
    rescue ArgumentError # rubocop:disable Lint/HandleExceptions
      # if date can't be parsed set as nil
    end

    def exclude_from_model
      occurred_on_fields
    end

    def occurred_on_fields
      %i[occurred_year occurred_month occurred_day]
    end

    def occurred_on_methods
      @occurred_on_methods ||= occurred_on_fields.map { |f| __send__(f) }
    end

    def occurred_on_from_model
      return unless model.occurred_on?

      {
        occurred_year: model.occurred_on.year,
        occurred_month: model.occurred_on.month,
        occurred_day: model.occurred_on.day
      }
    end

    def incomplete_date
      @incomplete_date = true unless occurred_on_methods.all?(&:blank?)
      nil
    end

    def incomplete_date?
      @incomplete_date
    end

    def draft_and_not_incomplete_date?
      draft? && !incomplete_date?
    end
  end
end
