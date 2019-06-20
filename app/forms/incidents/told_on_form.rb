module Incidents
  class ToldOnForm
    include BaseForm

    form_for Incident

    DATE_PARTS = %i[told_year told_month told_day occurred_year occurred_month occurred_day].freeze

    attr_accessor :told_year, :told_month, :told_day
    attr_writer :told_on

    attr_accessor :occurred_year, :occurred_month, :occurred_day
    attr_writer :occurred_on

    validates :told_on, presence: true, unless: :draft_and_not_incomplete_date?
    validates :told_on, date: { not_in_the_future: true }, allow_nil: true

    validates :occurred_on, presence: true, unless: :draft_and_not_incomplete_date?
    validates :occurred_on, date: { not_in_the_future: true }, allow_nil: true

    validate :occurred_before_told

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        # attrs: told_on_fields,
        # attrs: DATE_PARTS,
        # model_attributes: told_on_from_model,
        # attrs: (occurred_on_fields + told_on_fields),
        # model_attributes: (occurred_on_from_model + told_on_from_model)
        attrs: all_on_fields,
        model_attributes: all_on_from_model
      )
    end

    # def initialize(*args)
    #   super
    #   set_instance_variables_for_attributes_if_not_set_but_in_model(
    #     attrs: (told_on_fields + occurred_on_fields),
    #     model_attributes: (told_on_from_model && occurred_on_from_model)
    #     )
    # end

    def told_on
      return @told_on if @told_on.present?
      return incomplete_date if told_on_methods.any?(&:blank?)

      @told_on = attributes[:told_on] = Date.new(*told_on_methods.map(&:to_i))
    rescue ArgumentError
      :invalid
    end

    def occurred_on
      return @occurred_on if @occurred_on.present?
      return incomplete_date if occurred_on_methods.any?(&:blank?)

      @occurred_on = attributes[:occurred_on] = Date.new(*occurred_on_methods.map(&:to_i))
    rescue ArgumentError
      :invalid
    end

    private


    def occurred_before_told
      return if occurred_on.blank? || told_on.blank?

      if told_on < occurred_on
        errors.add(:occurred_on, :invalid_timeline)
      end
    rescue ArgumentError
      :invalid
    end

    def exclude_from_model
      %i[told_year told_month told_day occurred_year occurred_month occurred_day]
      # %i[told_on_fields incident_occurred_fields]
      # how do i just reference the 2 below instead of listing all 6
      # told_on_fields
      # occurred_on_fields
    end

    def told_on_fields
      %i[told_year told_month told_day]
    end

    def occurred_on_fields
      %i[occurred_year occurred_month occurred_day]
    end

    def all_on_fields
      %i[occurred_year occurred_month occurred_day told_year told_month told_day]
    end

    def told_on_methods
      @told_on_methods ||= told_on_fields.map { |f| __send__(f) }
    end

    def occurred_on_methods
      @occurred_on_methods ||= occurred_on_fields.map { |f| __send__(f) }
    end

    def told_on_from_model
      return unless model.told_on?

      {
        told_year: model.told_on.year,
        told_month: model.told_on.month,
        told_day: model.told_on.day
      }
    end

    def occurred_on_from_model
      return unless model.occurred_on?

      {
        occurred_year: model.occurred_on.year,
        occurred_month: model.occurred_on.month,
        occurred_day: model.occurred_on.day
      }
    end

    def all_on_from_model
      return unless model.occurred_on?

      {
        told_year: model.told_on.year,
        told_month: model.told_on.month,
        told_day: model.told_on.day,
        occurred_year: model.occurred_on.year,
        occurred_month: model.occurred_on.month,
        occurred_day: model.occurred_on.day
      }
    end

    def incomplete_date
      return nil if told_on_methods.all?(&:blank?) || occurred_on_methods.all?(&:blank?)

      @incomplete_date = true
      :invalid
    end

    # def incomplete_incident_date
    #   return nil if occurred_on_methods.all?(&:blank?)
    #
    #   @incomplete_incident_date = true
    #   :invalid
    # end

    def incomplete_date?
      @incomplete_date
    end

    def draft_and_not_incomplete_date?
      draft? && !incomplete_date?
    end
  end
end
