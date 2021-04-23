module Applicants
  class BasicDetailsForm
    include BaseForm

    ATTRIBUTES = %i[first_name last_name national_insurance_number
                    date_of_birth_1i date_of_birth_2i date_of_birth_3i].freeze

    form_for Applicant

    attr_accessor(*ATTRIBUTES)
    attr_writer :date_of_birth

    before_validation :normalise_national_insurance_number

    # Note order of validation here determines order they appear on page
    # So validations for each field need to be in order, and presence validations
    # split so that they occur in the right order.
    validates :first_name, :last_name, presence: true, unless: :draft?

    validates :date_of_birth, presence: true, unless: :draft_and_not_partially_complete_date_of_birth?

    validates(
      :date_of_birth,
      date: {
        not_in_the_future: true,
        earliest_allowed_date: { date: '1900-01-01' }
      },
      allow_nil: true
    )

    validates :national_insurance_number, presence: true, unless: :draft?
    validate :validate_national_insurance_number

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: dob_date_fields.fields,
        model_attributes: dob_date_fields.model_attributes
      )
    end

    def date_of_birth
      return @date_of_birth if @date_of_birth.present?
      return if dob_date_fields.blank?
      return dob_date_fields.input_field_values if dob_date_fields.partially_complete? || dob_date_fields.form_date_invalid?

      @date_of_birth = attributes[:date_of_birth] = dob_date_fields.form_date
    end

    def normalise_national_insurance_number
      return if national_insurance_number.blank?

      national_insurance_number.delete!(' ')
      national_insurance_number.upcase!
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
        model: model,
        method: :date_of_birth,
        prefix: :date_of_birth_,
        suffix: :gov_uk
      )
    end

    def validate_national_insurance_number
      return if draft? && national_insurance_number.blank?
      return if test_level_validation? && known_test_ninos.include?(national_insurance_number)
      return if Applicant::NINO_REGEXP.match?(national_insurance_number)

      errors.add(:national_insurance_number, :not_valid)
    end

    # These are the test ninos known to fail validation with Applicant::NINO_REGEXP
    # See https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/1298464776/Benefit+Checker
    def known_test_ninos
      %w[JS130161E NX794801E JD142369D NP685623E JR468684E JF982354B JK806648E JW570102E]
    end

    def test_level_validation?
      Rails.configuration.x.laa_portal.mock_saml == 'true'
    end
  end
end
