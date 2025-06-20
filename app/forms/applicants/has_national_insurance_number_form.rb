module Applicants
  class HasNationalInsuranceNumberForm < BaseForm
    include NationalInsuranceHandling

    form_for Applicant

    attr_accessor :has_national_insurance_number, :national_insurance_number

    before_validation :normalise_national_insurance_number

    validates :has_national_insurance_number, inclusion: ["true", "false", true, false], unless: :draft?
    validates :national_insurance_number, presence: true, if: :has_national_insurance_number?, unless: :draft?
    validate :validate_national_insurance_number
  end
end
