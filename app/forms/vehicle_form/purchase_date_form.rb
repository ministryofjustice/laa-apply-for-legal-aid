module VehicleForm
  class PurchaseDateForm
    include BaseForm

    form_for Vehicle

    attr_accessor :purchased_on_year, :purchased_on_month, :purchased_on_day
    attr_accessor :journey
    attr_writer :purchased_on

    validates :purchased_on, presence: true, unless: :draft_and_not_partially_complete_date?
    validates :purchased_on, date: { not_in_the_future: true }, allow_nil: true

    validate :date_is_in_the_future

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: purchased_on_date_fields.fields,
        model_attributes: purchased_on_date_fields.model_attributes
      )
    end

    def purchased_on
      return @purchased_on if @purchased_on.present?
      return if purchased_on_date_fields.blank?
      return :invalid if purchased_on_date_fields.partially_complete? || purchased_on_date_fields.form_date_invalid?

      @purchased_on = attributes[:purchased_on] = purchased_on_date_fields.form_date
    end

    private

    def exclude_from_model
      purchased_on_date_fields.fields + [:journey]
    end

    def purchased_on_date_fields
      @purchased_on_date_fields ||= DateFieldBuilder.new(
        form: self,
        model: model,
        method: :purchased_on,
        prefix: :purchased_on_
      )
    end

    def draft_and_not_partially_complete_date?
      draft? && !purchased_on_date_fields.partially_complete?
    end

    def date_is_in_the_future
      return if draft? || !purchased_on

      errors.add(:purchased_on, error_message_for(:date_is_in_the_future)) if purchased_on > Date.current
    end

    def error_message_for(error_type)
      I18n.t("activemodel.errors.models.vehicle.attributes.purchased_on.#{journey}.#{error_type}")
    end
  end
end
