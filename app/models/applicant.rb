require 'uri'
require 'omniauth'

class Applicant < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:true_layer]

  NINO_REGEXP = /^[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}$/.freeze

  has_one :legal_aid_application
  has_many :addresses
  has_one :address, -> { order(created_at: :desc) }
  has_many :bank_providers
  has_many :bank_errors

  validates :first_name, :last_name, :date_of_birth, :national_insurance_number, presence: true

  validate :validate_date_of_birth, :validate_national_insurance_number

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true

  def email_address
    email
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def dob
    {
      dob_year: date_of_birth.strftime('%Y'),
      dob_month: date_of_birth.strftime('%m'),
      dob_day: date_of_birth.strftime('%d')
    }
  end

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
    return if test_level_validation? && known_test_ninos.include?(national_insurance_number)

    errors.add(:national_insurance_number, :invalid) unless NINO_REGEXP =~ national_insurance_number
  end

  # These National Insurance Numbers are used for testing but do not match NINO_REGEXP
  def known_test_ninos
    %w[JS130161E NX794801E JD142369D NP685623E JR468684E JF982354B JK806648E JW570102E]
  end

  def test_level_validation?
    Rails.configuration.x.laa_portal.mock_saml == 'true'
  end
end
