module Dependants
  class BasicDetailsForm
    include BaseForm
    form_for Dependant

    ATTRIBUTES = %i[name dob_year dob_month dob_day].freeze

    attr_accessor :name, :dob_year, :dob_month, :dob_day
    attr_writer :date_of_birth

    validates :name, presence: true
    validates :date_of_birth, presence: true
    validates(
      :date_of_birth,
      date: {
        not_in_the_future: true,
        earliest_allowed_date: { date: '1900-01-01' }
      },
      allow_nil: true
    )

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: date_fields.fields,
        model_attributes: date_fields.model_attributes
      )
    end

    # Note that this method is first called by `validates`.
    # Without that validation, the functionality in this method will not be called before save
    def date_of_birth
      return @date_of_birth if @date_of_birth.present?
      return if date_fields.blank?
      return :invalid if date_fields.partially_complete? || date_fields.form_date_invalid?

      @date_of_birth = attributes[:date_of_birth] = date_fields.form_date
    end

    private

    def exclude_from_model
      date_fields.fields
    end

    def date_fields
      @date_fields ||= DateFieldBuilder.new(
        form: self,
        model: model,
        method: :date_of_birth,
        prefix: :dob_
      )
    end
  end
end
