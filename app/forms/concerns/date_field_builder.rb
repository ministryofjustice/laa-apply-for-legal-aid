class DateFieldBuilder
  DATE_PARTS = %i[year month day].freeze

  attr_reader :form, :model, :method, :prefix

  # :method is the target method on the model
  # :prefix is used to construct date part fields
  def initialize(form:, model:, method:, prefix:)
    @form = form
    @model = model
    @method = method
    @prefix = prefix
  end

  def blank?
    from_form.all?(&:blank?)
  end

  def complete?
    @complete ||= from_form.all?(&:present?)
  end

  def partially_complete?
    !blank? && !complete?
  end

  # Date part fields
  def fields
    DATE_PARTS.map { |part| field_for(part) }
  end

  # An array of the data stored in the form's date part fields
  def from_form
    @from_form ||= fields.map { |field| form.__send__(field) }
  end

  # A hash that can populate the form's date part fields from data in the model
  def model_attributes
    return unless model_date.present?

    DATE_PARTS.each_with_object({}) { |part, hash| hash[field_for(part)] = model_date.__send__(part) }
  end

  def model_date
    @model_date ||= model.__send__(method)
  end

  def form_date_invalid?
    !Date.valid_date?(*from_form.map(&:to_i))
  end

  def form_date
    @form_date ||= Date.new(*from_form.map(&:to_i))
  end

  private

  def field_for(part)
    [prefix, part].join.to_sym
  end
end
