module Applicants
  class HasNationalInsuranceNumberForm < BaseForm
    form_for Applicant

    attr_accessor :has_national_insurance_number, :national_insurance_number

    before_validation :normalise_national_insurance_number

    validates :has_national_insurance_number, inclusion: { in: %w[true false] }, unless: :draft?

    with_options unless: :draft?, if: :has_national_insurance_number? do |form|
      form.validates :national_insurance_number, presence: true
      form.validates :national_insurance_number, format: { with: Applicant::NINO_REGEXP }, unless: proc { national_insurance_number.blank? || skip_regex_validation? }
    end

  private

    def normalise_national_insurance_number
      attributes[:national_insurance_number] = nil unless has_national_insurance_number?
      return if national_insurance_number.blank?

      national_insurance_number.delete!(" ")
      national_insurance_number.upcase!
    end

    def skip_regex_validation?
      test_level_validation? && known_test_ninos.include?(national_insurance_number)
    end

    def skip_known_test_ninos?
      test_level_validation? && known_test_ninos.include?(national_insurance_number)
    end

    # These are the test ninos known to fail validation with Applicant::NINO_REGEXP
    # See https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/1298464776/Benefit+Checker
    def known_test_ninos
      %w[JS130161E NX794801E JD142369D NP685623E JR468684E JF982354B JK806648E JW570102E]
    end

    def test_level_validation?
      Rails.configuration.x.laa_portal.mock_saml == "true"
    end

    def has_national_insurance_number?
      has_national_insurance_number.eql?("true")
    end
  end
end
