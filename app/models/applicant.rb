class Applicant < ApplicationRecord
  has_one :legal_aid_application

  validates :first_name, :last_name, :date_of_birth, presence: true

  validate :validate_date_of_birth

  private

  def validate_date_of_birth
    errors.add(:date_of_birth, 'is not valid') if date_of_birth.present? && (date_of_birth < Date.new(1900, 0o1, 0o1) || date_of_birth > Date.today)
  end
end
