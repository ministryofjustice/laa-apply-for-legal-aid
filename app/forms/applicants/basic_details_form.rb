module Applicants
  class BasicDetailsForm
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    include BaseForm
    extend BaseForm::ClassMethods

    form_for Applicant

    attr_accessor :first_name, :last_name, :email_address, :national_insurance_number,
                  :date_of_birth, :dob_year, :dob_month, :dob_day

    NINO_REGEXP = /\A[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}\z/

    before_validation :normalise_national_insurance_number

    validates :first_name, :last_name, presence: true
    validates :national_insurance_number, presence: true, format: { with: NINO_REGEXP }
    validates :date_of_birth, presence: true, inclusion: { in: 120.years.ago..Time.now }
    validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :dob_year, format: { with: /\A\d{4}\z/ }, allow_nil: true
    validates :dob_month, format: { with: /\A((0?[1-9])|(1[0-2]))\z/ }, allow_nil: true
    validates :dob_day, format: { with: /\A(([0-2]?[1-9])|([1-3]0)|31)\z/ }, allow_nil: true

    def date_of_birth
      @date_of_birth ||= attributes[:date_of_birth] = Date.parse("#{dob_year}-#{dob_month}-#{dob_day}")
    rescue ArgumentError
      # if date can't be parsed set as nil
    end

    def model
      @model ||= legal_aid_application.build_applicant
    end

    def normalise_national_insurance_number
      return if national_insurance_number.nil?
      national_insurance_number.delete!(' ')
      national_insurance_number.upcase!
    end

    def exclude_from_model
      [:dob_year, :dob_month, :dob_day]
    end
  end
end
