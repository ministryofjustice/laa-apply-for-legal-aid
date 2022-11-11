module Applicants
  class BasicDetailsForm < BaseForm
    ATTRIBUTES = %i[first_name
                    last_name
                    date_of_birth_1i
                    date_of_birth_2i
                    date_of_birth_3i].freeze

    form_for Applicant

    attr_accessor(*ATTRIBUTES)
    attr_writer :date_of_birth

    before_validation do
      squish_whitespaces(:first_name, :last_name)
    end

    # Note order of validation here determines order they appear on page
    # So validations for each field need to be in order, and presence validations
    # split so that they occur in the right order.
    validates :first_name, presence: true, unless: proc { draft? && last_name.present? }
    validates :last_name, presence: true, unless: proc { draft? && first_name.present? }
    validates :date_of_birth, presence: true, unless: :draft_and_not_partially_complete_date_of_birth?

    validates(
      :date_of_birth,
      date: {
        not_in_the_future: true,
        earliest_allowed_date: { date: "1900-01-01" },
      },
      allow_nil: true,
    )

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: dob_date_fields.fields,
        model_attributes: dob_date_fields.model_attributes,
      )
    end

    def date_of_birth
      return @date_of_birth if @date_of_birth.present?
      return if dob_date_fields.blank?
      return dob_date_fields.input_field_values if dob_date_fields.partially_complete? || dob_date_fields.form_date_invalid?

      @date_of_birth = attributes[:date_of_birth] = dob_date_fields.form_date
    end

    def exclude_from_model
      dob_date_fields.fields
    end

    def draft_and_not_partially_complete_date_of_birth?
      draft? && !dob_date_fields.partially_complete?
    end

    def dob_date_fields
      @dob_date_fields ||= DateFieldBuilder.new(
        form: self,
        model:,
        method: :date_of_birth,
        prefix: :date_of_birth_,
        suffix: :gov_uk,
      )
    end
  end
end
