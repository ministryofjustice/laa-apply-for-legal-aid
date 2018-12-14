module Applicants
  class BasicDetailsForm
    include BaseForm

    form_for Applicant

    attr_accessor :first_name, :last_name, :national_insurance_number,
                  :dob_year, :dob_month, :dob_day, :email,
                  :legal_aid_application_id
    attr_writer :date_of_birth

    NINO_REGEXP = /\A[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}\z/.freeze

    before_validation :normalise_national_insurance_number

    validates :first_name, :last_name, presence: true

    validates(
      :date_of_birth,
      date: {
        not_in_the_future: true,
        earliest_allowed_date: { date: '1900-01-01' }
      }
    )

    validates :national_insurance_number, presence: true
    validates :national_insurance_number, format: { with: NINO_REGEXP, message: :not_valid }, allow_blank: true

    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    validates :email, presence: true

    # rubocop:disable Lint/HandleExceptions
    def date_of_birth
      @date_of_birth ||= attributes[:date_of_birth] = Date.parse("#{dob_year}-#{dob_month}-#{dob_day}")
    rescue ArgumentError
      # if date can't be parsed set as nil
    end
    # rubocop:enable Lint/HandleExceptions

    def model
      @model ||= legal_aid_application.applicant || legal_aid_application.build_applicant
    end

    def normalise_national_insurance_number
      return if national_insurance_number.blank?

      national_insurance_number.delete!(' ')
      national_insurance_number.upcase!
    end

    def exclude_from_model
      %i[dob_year dob_month dob_day legal_aid_application_id]
    end

    private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(legal_aid_application_id)
    end
  end
end
