module Incidents
  class ToldOnForm
    include BaseForm

    form_for Incident

    attr_accessor :told_year, :told_month, :told_day
    attr_writer :told_on

    validates :told_on, presence: true, unless: :draft_and_not_incomplete_date?
    validates :told_on, date: { not_in_the_future: true }, allow_nil: true

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: told_on_fields,
        model_attributes: told_on_from_model
      )
    end

    def told_on
      return @told_on if @told_on.present?
      return incomplete_date if told_on_methods.any?(&:blank?)

      @told_on = attributes[:told_on] = Date.new(*told_on_methods.map(&:to_i))
    rescue ArgumentError
      :invalid
    end

    private

    def exclude_from_model
      told_on_fields
    end

    def told_on_fields
      %i[told_year told_month told_day]
    end

    def told_on_methods
      @told_on_methods ||= told_on_fields.map { |f| __send__(f) }
    end

    def told_on_from_model
      return unless model.told_on?

      {
        told_year: model.told_on.year,
        told_month: model.told_on.month,
        told_day: model.told_on.day
      }
    end

    def incomplete_date
      return nil if told_on_methods.all?(&:blank?)

      @incomplete_date = true
      :invalid
    end

    def incomplete_date?
      @incomplete_date
    end

    def draft_and_not_incomplete_date?
      draft? && !incomplete_date?
    end
  end
end
