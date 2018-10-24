module Applicants
  class BasicDetailsForm
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    include BaseForm
    extend BaseForm::ClassMethods

    form_for Applicant

    attr_accessor :first_name, :last_name, :national_insurance_number,
                  :date_of_birth, :dob_year, :dob_month, :dob_day

    NINO_REGEXP = /\A[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}\z/

    before_validation :normalise_national_insurance_number

    validates :first_name, :last_name, :national_insurance_number, presence: true
    validates(
      :date_of_birth,
      date: {
        not_in_the_future: true,
        not_four_digit_year: true,
        earliest_allowed_date: { date: '1900-01-01' }
      }
    )
    validates :national_insurance_number, format: { with: NINO_REGEXP, message: :not_valid }, allow_blank: true

    # rubocop:disable Lint/DuplicateMethods
    # rubocop:disable Lint/HandleExceptions
    def date_of_birth
      @date_of_birth ||= attributes[:date_of_birth] = Date.parse("#{dob_year}-#{dob_month}-#{dob_day}")
    rescue ArgumentError
      # if date can't be parsed set as nil
    end
    # rubocop:enable Lint/DuplicateMethods
    # rubocop:enable Lint/HandleExceptions

    def model
      @model ||= legal_aid_application.build_applicant
    end

    def normalise_national_insurance_number
      return if national_insurance_number.blank?
      national_insurance_number.delete!(' ')
      national_insurance_number.upcase!
    end

    def exclude_from_model
      %i[dob_year dob_month dob_day]
    end
  end
end
