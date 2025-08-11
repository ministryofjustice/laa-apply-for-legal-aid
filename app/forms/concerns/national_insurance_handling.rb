module NationalInsuranceHandling
  extend ActiveSupport::Concern

  included do
  private

    def has_national_insurance_number?
      has_national_insurance_number.in?(["true", true])
    end

    def normalise_national_insurance_number
      attributes[:national_insurance_number] = nil unless has_national_insurance_number?
      return if national_insurance_number.blank?

      national_insurance_number.delete!(" ")
      national_insurance_number.upcase!
    end

    def test_level_validation?
      Rails.configuration.x.omniauth_entraid.mock_auth
    end

    def validate_national_insurance_number
      return unless has_national_insurance_number?
      return if draft? && national_insurance_number.blank?
      return if skip_known_test_ninos?
      return if Applicant::NINO_REGEXP.match?(national_insurance_number)

      errors.add(:national_insurance_number, :not_valid)
    end

    def skip_known_test_ninos?
      test_level_validation? && known_test_ninos.include?(national_insurance_number)
    end

    # These are the test ninos known to fail validation with Applicant::NINO_REGEXP
    # See https://dsdmoj.atlassian.net/wiki/spaces/ATPPB/pages/1298464776/Benefit+Checker
    def known_test_ninos
      %w[JS130161E NX794801E JD142369D NP685623E JR468684E JF982354B JK806648E JW570102E]
    end
  end
end
