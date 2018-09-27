require 'uri'

class Applicant < ApplicationRecord
  has_one :legal_aid_application

  validates :first_name, :last_name, :date_of_birth, :national_insurance_number, presence: true

  validate :validate_date_of_birth

  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true

  private

  def validate_date_of_birth
    errors.add(:date_of_birth, 'is not valid') if date_of_birth.present? && (date_of_birth < Date.new(1900, 0o1, 0o1) || date_of_birth > Date.today)
  end
end
