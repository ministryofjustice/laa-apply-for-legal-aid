require 'uri'

class Applicant < ApplicationRecord
  NINO_REGEXP = /^[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}$/

  has_one :legal_aid_application
  has_many :addresses

  validates :first_name, :last_name, :date_of_birth, :national_insurance_number, presence: true

  validate :validate_date_of_birth, :validate_national_insurance_number

  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true

  private

  def validate_date_of_birth
    errors.add(:date_of_birth, :invalid) if date_of_birth.present? && (date_of_birth < Date.new(1900, 0o1, 0o1) || date_of_birth > Date.today)
  end

  def normalise_national_insurance_number
    return unless national_insurance_number
    national_insurance_number.delete!(' ')
    national_insurance_number.upcase!
  end

  def validate_national_insurance_number
    return if national_insurance_number.blank?
    normalise_national_insurance_number
    errors.add(:national_insurance_number, :invalid) unless NINO_REGEXP =~ national_insurance_number
  end
end
