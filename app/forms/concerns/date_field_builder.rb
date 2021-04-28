class DateFieldBuilder
  YearError = Class.new(StandardError)

  DATE_PARTS = %i[year month day].freeze
  FORM_PARTS = %i[1i 2i 3i].freeze

  attr_reader :form, :model, :method, :prefix, :label

  # :method is the target method on the model
  # :prefix is used to construct date part fields
  def initialize(form:, model:, method:, prefix:, suffix: :date, label: nil)
    @form = form
    @model = model
    @method = method
    @prefix = prefix
    @suffix = suffix
    @label = label || method
  end

  def blank?
    from_form.all?(&:blank?)
  end

  def complete?
    @complete ||= from_form.all?(&:present?)
  end

  def partially_complete?
    present? && !complete?
  end

  def all_numeric?
    from_form.map { |x| numeric?(x) }.uniq == [true]
  end

  def not_all_numeric?
    !all_numeric?
  end

  def numeric?(field)
    /^\d+$/.match?(field.to_s)
  end

  # Date part fields
  def fields
    target = @suffix.eql?(:gov_uk) ? FORM_PARTS : DATE_PARTS
    target.map { |part| field_for(part) }
  end

  # An array of the data stored in the form's date part fields
  def from_form
    @from_form ||= fields.map { |field| form.__send__(field) }
  end

  def parts_hash
    DATE_PARTS.zip(fields).to_h
  end

  # A hash that can populate the form's date part fields from data in the model
  def model_attributes
    return if model_date.blank?

    DATE_PARTS.each_with_object({}) { |part, hash| hash[parts_hash[part]] = model_date.__send__(part) }
  end

  def model_date
    @model_date ||= model.__send__(method)
  end

  def form_date_invalid?
    return true if not_all_numeric?

    !Date.valid_date?(*date_attributes)
  rescue YearError
    true
  end

  def form_date
    @form_date ||= Date.new(*date_attributes)
  end

  def input_field_values
    [''] + from_form
  end

  private

  def field_for(part)
    [prefix, part].join.to_sym
  end

  def date_attributes
    year, month, day = from_form
    [four_digit_year(year), month, day].map(&:to_i)
  end

  def four_digit_year(year)
    year = year.to_s

    case year.length
    when 4
      year
    when 2
      year > Time.current.strftime('%y') ? "19#{year}" : "20#{year}"
    else
      raise YearError, 'Year is incorrect length'
    end
  end
end
