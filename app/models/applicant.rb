require 'date'

class Applicant < ApplicationRecord

  has_one :legal_aid_application

  validates :name, :date_of_birth, presence: true

  validate :validate_date_of_birth

  private

  def validate_date_of_birth
    if date_of_birth.present? && (date_of_birth < Date.new(1900, 01, 01) || date_of_birth > Date.today)
       errors.add(:date_of_birth, "Date of birth is not valid")
    end
  end
end
