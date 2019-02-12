module Applicants
  class BasicDetailsForm
    include BaseForm

    form_for Applicant

    attr_accessor :first_name, :last_name, :national_insurance_number,
                  :dob_year, :dob_month, :dob_day, :email
    attr_writer :date_of_birth

    before_validation :normalise_national_insurance_number

    validates :email, :first_name, :last_name, :national_insurance_number, presence: true, unless: :draft?

    validates :date_of_birth, presence: true, unless: :draft_and_not_incomplete_date?

    validates(
      :date_of_birth,
      date: {
        not_in_the_future: true,
        earliest_allowed_date: { date: '1900-01-01' }
      },
      allow_nil: true
    )

    validate :validate_national_insurance_number

    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

    def initialize(*args)
      super
      set_instance_variables_for_attributes_if_not_set_but_in_model(
        attrs: dob_fields,
        model_attributes: dob_from_model
      )
    end

    # rubocop:disable Lint/HandleExceptions
    def date_of_birth
      return @date_of_birth if @date_of_birth.present?
      return incomplete_date if dobs.any?(&:blank?)

      @date_of_birth = attributes[:date_of_birth] = Date.new(*dobs.map(&:to_i))
    rescue ArgumentError
      # if date can't be parsed set as nil
    end
    # rubocop:enable Lint/HandleExceptions

    def normalise_national_insurance_number
      return if national_insurance_number.blank?

      national_insurance_number.delete!(' ')
      national_insurance_number.upcase!
    end

    def exclude_from_model
      dob_fields
    end

    def dob_fields
      %i[dob_year dob_month dob_day]
    end

    def dobs
      @dobs ||= [dob_year, dob_month, dob_day]
    end

    def dob_from_model
      return unless model.date_of_birth?

      {
        dob_year: model.date_of_birth.year,
        dob_month: model.date_of_birth.month,
        dob_day: model.date_of_birth.day
      }
    end

    def validate_national_insurance_number
      return if draft? && national_insurance_number.blank?
      return if test_level_validation? && known_test_ninos.include?(national_insurance_number)
      return if Applicant::NINO_REGEXP =~ national_insurance_number

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

    def incomplete_date
      @incomplete_date = true unless dobs.all?(&:blank?)
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
